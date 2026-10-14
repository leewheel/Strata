import argparse, json, os, sys, threading, time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import urllib.error, urllib.request, msvcrt

DEFAULT_THREADS = 24
DEFAULT_CHUNK_MB = 256


def lock_single_instance(lock_path):
    return -1


def release_single_instance(fd):
    pass


def http_head_size(url, timeout=30):
    try:
        req = urllib.request.Request(url, method="HEAD")
        req.add_header("User-Agent", "strata-fastdl/1.0")
        with urllib.request.urlopen(req, timeout=timeout) as r:
            cl = r.headers.get("Content-Length")
            if cl and cl.isdigit():
                return int(cl)
    except Exception:
        pass
    return None


def http_range_total(url, timeout=30):
    try:
        req = urllib.request.Request(url, method="GET",
                                      headers={"Range": "bytes=0-0", "User-Agent": "strata-fastdl/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as r:
            cr = r.headers.get("Content-Range")
            if cr and "-" in cr:
                total = cr.split("/")[-1].strip()
                if total.isdigit():
                    return int(total)
    except Exception:
        pass
    return None


def resolve_url(urls):
    for u in urls:
        if http_head_size(u) is not None or http_range_total(u) is not None:
            return u
    return None


def choose_source(main_urls, fallback_urls):
    chosen = resolve_url(main_urls)
    if chosen:
        return chosen, "main"
    chosen = resolve_url(fallback_urls)
    if chosen:
        return chosen, "fallback"
    return None, None


def download(url, dest, progress, thread_count, chunk_mb, name):
    print(f"[DBG] download start {name} threads={thread_count} chunk_mb={chunk_mb}", flush=True)
    chunk_bytes = chunk_mb * 1024 * 1024
    total = http_range_total(url)
    if total is None:
        total = http_head_size(url)
    if total is None:
        raise RuntimeError(f"cannot determine total size for {name}")
    print(f"[DBG] total={total}", flush=True)
    responselock = threading.Lock()
    done = {"bytes": 0}
    tmp = dest.with_suffix(dest.suffix + ".tmp")
    progress_path = dest.with_name(dest.name + ".progress.json")

    def fetch_range(start):
        end = min(start + chunk_bytes - 1, total - 1)
        headers = {"Range": f"bytes={start}-{end}", "User-Agent": "strata-fastdl/1.0"}
        attempt = 0
        while True:
            try:
                attempt += 1
                if attempt == 1 or attempt % 5 == 0:
                    print(f"[DL] range {start}-{end} attempt {attempt}", flush=True)
                req = urllib.request.Request(url, headers=headers)
                print(f"[DL] urlopen {start}-{end}", flush=True)
                with urllib.request.urlopen(req, timeout=30) as r:
                    print(f"[DL] reading {start}-{end}", flush=True)
                    data = r.read()
                print(f"[DL] got {len(data)} bytes for {start}-{end}", flush=True)
                with responselock:
                    with open(tmp, "r+b") as f:
                        f.seek(start)
                        f.write(data)
                    done["bytes"] += len(data)
                    pct = round(100.0 * done["bytes"] / total, 1)
                    progress["bytes"] = done["bytes"]
                    progress["total"] = total
                    progress["pct"] = pct
                    with open(progress_path, "w") as pf:
                        json.dump(progress, pf)
                print(f"[DL] range done {start}-{end}", flush=True)
                return
            except Exception as e:
                if attempt % 3 == 0:
                    print(f"[DL] err {start}-{end}: {type(e).__name__}", flush=True)
                time.sleep(1)

    tmp.parent.mkdir(parents=True, exist_ok=True)
    with open(tmp, "ab") as f:
        cur = f.tell()
    print(f"[DBG] cur={cur}", flush=True)
    if cur < total:
        print(f"[DBG] fresh/resume, skipping pre-truncate", flush=True)
    progress["bytes"] = cur
    progress["total"] = total
    progress["pct"] = round(100.0 * cur / total, 1)
    with open(progress_path, "w") as pf:
        json.dump(progress, pf)
    offsets = list(range(0, total, chunk_bytes))
    print(f"[DBG] starting executor with {len(offsets)} ranges", flush=True)
    with ThreadPoolExecutor(max_workers=thread_count) as ex:
        ex.map(fetch_range, offsets)
    srv = http_range_total(url)
    local = tmp.stat().st_size
    if srv is not None and local != srv:
        print(f"SERVER SIZE MISMATCH {name}: local={local}, server_total={srv}")
        tmp.unlink(missing_ok=True)
        progress_path.unlink(missing_ok=True)
        sys.exit(1)
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp.rename(dest)
    progress["status"] = "done"
    with open(progress_path, "w") as pf:
        json.dump(progress, pf)
    print(f"DONE {name} {local} bytes")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out-dir", required=True)
    p.add_argument("--files", nargs="+", required=True)
    p.add_argument("--main", nargs="+", required=True)
    p.add_argument("--fallback", nargs="+", required=True)
    p.add_argument("--threads", type=int, default=DEFAULT_THREADS)
    p.add_argument("--chunk-mb", type=int, default=DEFAULT_CHUNK_MB)
    args = p.parse_args()
    n = len(args.files)
    if len(args.main) != n or len(args.fallback) != n:
        sys.exit("counts of --files, --main, --fallback must match")
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    lock_path = out_dir / "fastdl.lock"
    fd = lock_single_instance(lock_path)
    if fd is None:
        sys.exit("another fastdl is running in this folder")
    try:
        for name, mu, fu in zip(args.files, args.main, args.fallback):
            dest = out_dir / name
            progress_path = dest.with_name(dest.name + ".progress.json")
            progress = {"bytes": dest.stat().st_size if dest.exists() else 0,
                        "total": 0, "pct": 0.0, "status": "queued"}
            main_urls = [mu.format(name=name)]
            fb_urls = [fu.format(name=name)]
            url, source = choose_source(main_urls, fb_urls)
            if url is None:
                print(f"NO SOURCE for {name}: main={mu} fallback={fu}")
                sys.exit(1)
            print(f"using {source}: {url}")
            progress["status"] = "downloading"
            with open(progress_path, "w") as pf:
                json.dump(progress, pf)
            download(url, dest, progress, args.threads, args.chunk_mb, name)
    finally:
        release_single_instance(fd)


if __name__ == "__main__":
    main()
