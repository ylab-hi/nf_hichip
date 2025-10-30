# nf_hichip

A simple nextflow pipeline for HiChIP data processing. Clone and update `samplesheet.csv'.

## Requirements

- Pipeline expects a `juicer` container in the `containers/` folder. You can find it [here](https://github.com/ArimaGenomics/Juicer_pipeline_containers).
- Make sure to have a `nextflow.config` file for SLURM, etc.
