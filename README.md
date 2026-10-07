# CORSIKA in-ice Cherenkov shower generator

> **Status: work in progress.** The model is still being improved, and the generated
> showers do not yet fully match CORSIKA 8. Use them for testing and visualization only.

Generates new 1 TeV CORSIKA 8 in-ice showers: the number of Cherenkov photons in
every lit 2 cm voxel of a 4 m box (192³ grid, light with time < 12 ns).
The trained model is in `trained_model/`; no input data is needed.

## Generate

```bash
git clone https://github.com/qwang552/corsika_cherenkov_generator.git
cd corsika_cherenkov_generator
pip install -r requirements.txt
python generate.py --n 10
```

This writes `showers/shower_00000.npz` ... `shower_00009.npz`. Options (all optional):

| option | default | meaning |
|---|---|---|
| `--n` | 10 | number of showers |
| `--out` | `showers` | output folder |
| `--seed` | 0 | shower n uses seed + n; the same seed gives the same showers |
| `--model` | `trained_model` | model folder |

A GPU is used when one is available; otherwise it runs on the CPU automatically. On a CPU one shower takes about 10 minutes.
A second run with a larger `--n` only adds the missing files.

## On the cluster (HTCondor, GPU)

Change the two paths at the top of `jobs/generate.sub` (`code_dir` = this folder,
`env_activate` = your python environment), then submit from a scratch directory:

```bash
condor_submit N=100 /path/to/corsika_cherenkov_generator/jobs/generate.sub
condor_submit N=100 OUT=/path/to/my_showers /path/to/corsika_cherenkov_generator/jobs/generate.sub
```

## Output

Each `shower_NNNNN.npz` lists every lit voxel:

| key | shape | meaning |
|---|---|---|
| `xyz` | (N, 3) | position [m] |
| `nphotons` | (N,) | number of Cherenkov photons |
| `ijk` | (N, 3) | voxel index on the 192³ grid |
| `box_m` | (3, 2) | x, y, z extent of the box [m] |

```python
import numpy as np
s = np.load("showers/shower_00000.npz")
xyz, nphotons = s["xyz"], s["nphotons"]
```

To plot them, open `view_showers.ipynb` and run all cells.

## What is in this repository

| path | what |
|---|---|
| `generate.py` | the command above |
| `trained_model/` | trained weights (float16) and the statistics the model needs |
| `sparseshower/` | model code, copied unchanged from the training code |
| `jobs/generate.sub`, `run_generate.sh` | HTCondor GPU job |
| `view_showers.ipynb` | plots: projections, 3D view, profile along the shower axis |

The model: noise → latent diffusion transformer → coarse 48³ field → sparse
structure model (48 → 96 → 192) → photons per voxel. Training code and evaluation:
https://github.com/qwang552/corsika_sparse_v2. All showers are 1 TeV; the model is not
yet conditioned on energy or angle.
