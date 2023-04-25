#!/usr/bin/env nextflow
nextflow.enable.dsl=2

log.info """\
    F L Y E - O N - C L U S T E R!!   
    ===============================
    """
    .stripIndent()

process assemble {
    // INPUT (Fasta)
    // OUTPUT (flye output dir)
    
    tag "$name"
    
    publishDir "${params.input_s3}/flye_${name}", mode: 'copy'
    cpus = params.flye_cpu
    memory = params.flye_ram
    disk = params.flye_disk
    errorStrategy 'finish'


    input: 
        tuple val(name) path(reads_fa)
    output:
        path "flye_${name}"

    script:
    """
    flye --nano-hq ${reads_fa} -o flye_${name} -t ${task.cpus} --meta
    """
}

workflow {
    s3_input_ch = Channel.fromPath("${params.input_s3}/*.fastq.gz", type: "file" ).view()
    s3_with_names = s3_input_ch.map{[it.name.toString().split('.fastq.gz')[0],it]}.view()
    assemble_ch = assemble(s3_with_names)
}