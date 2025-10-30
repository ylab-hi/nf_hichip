#!/usr/bin/env nextflow

process PAIRTOOLS_DEDUP {
    tag "$sample"
    
    container "https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/59/591e43b4619c63ff4c5dac3f7f4e1c34883235f16423bc3a6b0821adefe96fea/data"
    
    cpus 8
    memory '16.GB'
    time '24.h'

    
    publishDir "${params.outdir}/pairtools/dedup", mode: 'copy'

    input:
    tuple val(sample), path(pairfile), val(condition)
    
    output:
    tuple val(sample), path("${sample}.nodups.pairs.gz"), val(condition), emit: pairs
    tuple val(sample), path("${sample}.nodups.bam"), val(condition), emit: bam
    tuple val(sample), path("${sample}.unmapped.pairs.gz"), val(condition), emit: unmapped_pairs  // New
    tuple val(sample), path("${sample}.unmapped.bam"), val(condition), emit: unmapped_bam        // New
    tuple val(sample), path("${sample}.dups.pairs.gz"), val(condition), emit: dups_pairs         // New
    tuple val(sample), path("${sample}.dups.bam"), val(condition), emit: dups_bam                // New
    tuple val(sample), path("${sample}.dedup.stats"), val(condition), emit: dedup_stats                // New
    tuple val(sample), path("${sample}.stats"), val(condition), emit: stats  // New

    script:
    """
    pairtools dedup \
    --max-mismatch 3 \
    --mark-dups \
    --output \
        >( pairtools split \
            --output-pairs "${sample}".nodups.pairs.gz \
            --output-sam "${sample}".nodups.bam \
         ) \
    --output-unmapped \
        >( pairtools split \
            --output-pairs "${sample}".unmapped.pairs.gz \
            --output-sam "${sample}".unmapped.bam \
         ) \
    --output-dups \
        >( pairtools split \
            --output-pairs "${sample}".dups.pairs.gz \
            --output-sam "${sample}".dups.bam \
         ) \
    --output-stats "${sample}".dedup.stats \
    "${pairfile}"

    pairtools stats -o "${sample}".stats "${sample}".nodups.pairs.gz
    """
}

