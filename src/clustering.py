from heapq import heappush
from typing import Callable, Dict, IO, List, Set, Sequence, Tuple, TypeVar

import argparse
import numpy as np  # type: ignore
import re


def read_t_values(t_values_fp: IO[str]) -> np.ndarray:
    T = TypeVar("T")

    def read_t_value_row(line: str, cls: Callable[[str], T]) -> Sequence[T]:
        return [cls(ch) for ch in line.strip().split(",")]

    channels = read_t_value_row(t_values_fp.readline(), int)
    constraints = read_t_value_row(t_values_fp.readline(), float)
    meanings = read_t_value_row(t_values_fp.readline(), float)
    talkers = read_t_value_row(t_values_fp.readline(), float)
    assert len(channels) == len(constraints) == len(meanings) == len(talkers)
    return np.array((channels, constraints, meanings, talkers)).transpose()


def read_coords(coords_fp: IO[str], n_rows: int) -> np.ndarray:
    COORD_RE = re.compile(r"^E(\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s*$")
    df = np.zeros((n_rows, 3))
    i = 0
    for line in coords_fp:
        match = COORD_RE.match(line)
        if not match:
            continue
        x = float(match.group(2))
        y = float(match.group(3))
        z = float(match.group(4))
        df[i] = (x, y, z)
        i += 1
    return df


def load_data(t_values_fp: IO[str], coords_fp: IO[str]) -> np.ndarray:
    t_values = read_t_values(t_values_fp)
    coords = read_coords(coords_fp, t_values.shape[0])
    return np.concatenate((t_values, coords), axis=1)


def dist(a: np.ndarray, b: np.ndarray) -> float:
    return np.sqrt((a[4] - b[4]) ** 2 + (a[5] - b[5]) ** 2 + (a[6] - b[6]) ** 2)


RowIndex = int
Distance = float
NearestNeighbors = List[Tuple[Distance, RowIndex]]


def calc_nearest_neighbors(
    df: np.ndarray, n_neighbors: int
) -> Dict[RowIndex, NearestNeighbors]:
    all_nearest_neighbors: Dict[RowIndex, NearestNeighbors] = {}
    for this_index, this_row in enumerate(df):
        nearest_neighbors: NearestNeighbors = []
        for neighbor_index, neighbor_row in enumerate(df):
            if this_index == neighbor_index:
                continue
            d = dist(this_row, neighbor_row)
            heappush(nearest_neighbors, (d, neighbor_index))
            if len(nearest_neighbors) > n_neighbors:
                nearest_neighbors = nearest_neighbors[:n_neighbors]
        all_nearest_neighbors[this_index] = nearest_neighbors
    return all_nearest_neighbors


def calc_significant_neighbors(
    df: np.ndarray,
    nearest_neighbors: Dict[RowIndex, NearestNeighbors],
    col: int,
    min_significance: float,
) -> Dict[RowIndex, Sequence[RowIndex]]:
    all_significant_neighbors: Dict[RowIndex, Sequence[RowIndex]] = {}
    for i, row in enumerate(df):
        is_significant = row[col] >= min_significance
        if not is_significant:
            continue
        significant_neighbors = [
            j for _, j in nearest_neighbors[i] if df[j][col] >= min_significance
        ]
        if not significant_neighbors:
            continue
        all_significant_neighbors[i] = significant_neighbors
    return all_significant_neighbors


def calc_clusters(
    significant_neighbors: Dict[RowIndex, Sequence[RowIndex]]
) -> Set[Tuple[RowIndex, ...]]:
    clusters: Dict[RowIndex, Set[RowIndex]] = {}
    for src_index, neighbors in significant_neighbors.items():
        cluster: Set[RowIndex] = set([src_index, *neighbors])
        for i in set(cluster):
            if i in clusters:
                cluster |= clusters[i]
        for i in cluster:
            clusters[i] = cluster
    return set(tuple(sorted(c)) for c in clusters.values())


def main(
    t_values_fp: IO[str], coords_fp: IO[str], n_neighbors: int, min_significance: float
) -> None:
    df = load_data(t_values_fp, coords_fp)
    nearest_neighbors = calc_nearest_neighbors(df, n_neighbors)

    t_value_columns = (1, 2, 3)
    for col in t_value_columns:
        all_significant_neighbors = calc_significant_neighbors(
            df, nearest_neighbors, col, min_significance
        )
        print(calc_clusters(all_significant_neighbors))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("t_values_fp", type=argparse.FileType("r"))
    parser.add_argument("coords_fp", type=argparse.FileType("r"))
    parser.add_argument("--n-neighbors", type=int, required=True)
    parser.add_argument("--min-significance", type=float, required=True)
    args = parser.parse_args()

    main(args.t_values_fp, args.coords_fp, args.n_neighbors, args.min_significance)
