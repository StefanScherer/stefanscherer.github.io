#!/usr/bin/env python3
"""Build map assets from daily GPX files.

Creates:
- route.geojson with stage points for the existing trip map UI.
- Optional merged GPX containing all day tracks as separate segments.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional


@dataclass
class TrackPoint:
    lat: float
    lon: float
    time: Optional[dt.datetime] = None


@dataclass
class DayTrack:
    file: Path
    points: List[TrackPoint]


DATE_RE_1 = re.compile(r"(\d{4})-(\d{2})-(\d{2})")
DATE_RE_2 = re.compile(r"(\d{4})(\d{2})(\d{2})")


def parse_time(value: str) -> Optional[dt.datetime]:
    value = (value or "").strip()
    if not value:
        return None
    if value.endswith("Z"):
        value = value[:-1] + "+00:00"
    try:
        return dt.datetime.fromisoformat(value)
    except ValueError:
        return None


def parse_gpx_points(path: Path) -> List[TrackPoint]:
    tree = ET.parse(path)
    root = tree.getroot()

    out: List[TrackPoint] = []

    for p in root.findall(".//{*}trkpt") + root.findall(".//{*}rtept"):
        lat = p.get("lat")
        lon = p.get("lon")
        if lat is None or lon is None:
            continue
        t_el = p.find("{*}time")
        t = parse_time(t_el.text) if t_el is not None and t_el.text else None
        out.append(TrackPoint(lat=float(lat), lon=float(lon), time=t))

    return out


def detect_date(day: DayTrack) -> Optional[dt.date]:
    for p in day.points:
        if p.time is not None:
            return p.time.date()

    stem = day.file.stem
    m = DATE_RE_1.search(stem)
    if m:
        return dt.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))

    m = DATE_RE_2.search(stem)
    if m:
        return dt.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))

    return None


def format_date(d: Optional[dt.date]) -> str:
    if d is None:
        return ""
    return d.strftime("%d.%m.%Y")


def filename_to_title(path: Path) -> str:
    stem = path.stem
    stem = re.sub(r"^\d{4}-\d{2}-\d{2}[-_ ]*", "", stem)
    stem = re.sub(r"^\d{8}[-_ ]*", "", stem)
    title = stem.replace("_", " ").replace("-", " ")
    title = re.sub(r"\s+", " ", title).strip()
    if not title:
        return "Etappe"
    return title[:1].upper() + title[1:]


def build_geojson(days: Iterable[DayTrack], start_name: str) -> dict:
    features = []
    order = 1

    days_list = list(days)
    if not days_list:
        return {"type": "FeatureCollection", "features": []}

    first = days_list[0]
    first_date = detect_date(first)

    start = first.points[0]
    features.append(
        {
            "type": "Feature",
            "geometry": {"type": "Point", "coordinates": [start.lon, start.lat]},
            "properties": {
                "order": order,
                "name": start_name,
                "day": 1,
                "date": format_date(first_date),
            },
        }
    )
    order += 1

    for idx, day in enumerate(days_list, start=1):
        end = day.points[-1]
        features.append(
            {
                "type": "Feature",
                "geometry": {"type": "Point", "coordinates": [end.lon, end.lat]},
                "properties": {
                    "order": order,
                    "name": filename_to_title(day.file),
                    "day": idx,
                    "date": format_date(detect_date(day)),
                },
            }
        )
        order += 1

    return {"type": "FeatureCollection", "features": features}


def write_merged_gpx(days: Iterable[DayTrack], output_path: Path, track_name: str) -> None:
    ns = "http://www.topografix.com/GPX/1/1"
    ET.register_namespace("", ns)

    root = ET.Element(
        "{%s}gpx" % ns,
        {
            "version": "1.1",
            "creator": "gpx_tracks_to_map_assets.py",
        },
    )

    trk = ET.SubElement(root, "{%s}trk" % ns)
    name_el = ET.SubElement(trk, "{%s}name" % ns)
    name_el.text = track_name

    for day in days:
        seg = ET.SubElement(trk, "{%s}trkseg" % ns)
        for p in day.points:
            trkpt = ET.SubElement(
                seg,
                "{%s}trkpt" % ns,
                {
                    "lat": f"{p.lat:.7f}",
                    "lon": f"{p.lon:.7f}",
                },
            )
            if p.time is not None:
                t = ET.SubElement(trkpt, "{%s}time" % ns)
                t.text = p.time.astimezone(dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    tree = ET.ElementTree(root)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    tree.write(output_path, encoding="utf-8", xml_declaration=True)


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Build route.geojson and optional merged GPX from daily GPX files")
    p.add_argument("--gpx-dir", required=True, help="Directory containing day-wise GPX files")
    p.add_argument("--geojson-out", required=True, help="Output path for route.geojson")
    p.add_argument("--gpx-out", help="Optional output path for merged GPX file")
    p.add_argument("--start-name", default="Start", help="Label for first point")
    p.add_argument("--track-name", default="Reiseroute", help="Track name for merged GPX")
    return p.parse_args()


def main() -> int:
    args = parse_args()

    gpx_dir = Path(args.gpx_dir)
    if not gpx_dir.is_dir():
        raise SystemExit(f"GPX directory does not exist: {gpx_dir}")

    gpx_files = sorted(gpx_dir.glob("*.gpx"))
    if not gpx_files:
        raise SystemExit(f"No GPX files found in: {gpx_dir}")

    days: List[DayTrack] = []
    for f in gpx_files:
        points = parse_gpx_points(f)
        if not points:
            continue
        days.append(DayTrack(file=f, points=points))

    if not days:
        raise SystemExit("No track points found in GPX files.")

    geo = build_geojson(days, start_name=args.start_name)
    geo_out = Path(args.geojson_out)
    geo_out.parent.mkdir(parents=True, exist_ok=True)
    geo_out.write_text(json.dumps(geo, indent=2), encoding="utf-8")

    if args.gpx_out:
        write_merged_gpx(days, Path(args.gpx_out), args.track_name)

    print(f"Wrote {geo_out}")
    if args.gpx_out:
        print(f"Wrote {args.gpx_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
