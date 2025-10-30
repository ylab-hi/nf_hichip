/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    FASTP Module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Simple example module that demonstrates basic module structure
*/

process FASTP {
    tag "$sample"
    label 'process_low'

    container "https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/71/7180d4f5ff01f33209c7b39b31277d416bffe8d221149a25894805afc9755835/data"

    
    publishDir "${params.outdir}/trimmed_reads", mode: 'copy'
    
    input:
    tuple val(sample), path(read1), path(read2), val(condition)
    
    output:
    tuple val(sample), 
          path("${sample}_R1.trimmed.fastq.gz"), 
          path("${sample}_R2.trimmed.fastq.gz"), 
          val(condition),
          emit: trimmed_reads
    path "${sample}.html",          emit: html_report
    path "${sample}.json",          emit: json_report
    path "versions.yml",            emit: versions
    
    script:
    """
    fastp \\
        -i $read1 \\
        -I $read2 \\
        -o "${sample}_R1.trimmed.fastq.gz" \\
        -O "${sample}_R2.trimmed.fastq.gz" \\
        -h "${sample}.html" \\
        -j "${sample}.json" \\
        -w ${task.cpus} \\
        --detect_adapter_for_pe \\
        --qualified_quality_phred 20 \\
        --length_required 50


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
    END_VERSIONS
    """
    
    stub:
    """
    touch "${sample}_R1.trimmed.fastq.gz"
    touch "${sample}_R2.trimmed.fastq.gz"
    touch "${sample}.html"
    touch "${sample}.json"
    touch "versions.yml"
    """
}