#!/usr/bin/env nextflow

process PAIRTOOLS_PARSE {
    tag "$sample"
    
    container "https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/59/591e43b4619c63ff4c5dac3f7f4e1c34883235f16423bc3a6b0821adefe96fea/data"
    
    cpus 8
    memory '16.GB'
    time '24.h'

    input:
    tuple val(sample), path(bam), val(condition)
    path(chroms_file)
    
    output:
    tuple val(sample), path("${sample}_parsed.pairs"), val(condition), emit: parsed
    
    script:
    """
    pairtools parse \\
        --min-mapq 40 \\
        --walks-policy 5unique \\
        --chroms-path ${chroms_file} \\
        --output-stats ${sample}_parse_stats.txt \\
        --assembly hg38 \\
        ${bam} > ${sample}_parsed.pairs
    """
}