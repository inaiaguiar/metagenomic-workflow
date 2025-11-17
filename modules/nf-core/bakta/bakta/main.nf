process BAKTA_BAKTA {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bakta:1.10.4--pyhdfd78af_0' :
        'quay.io/biocontainers/bakta:1.11.3--pyhdfd78af_0' }"

    publishDir { "${params.outdir}/${meta.meta_id}/Bakta/" }, mode: 'copy'

    input:
    tuple val(meta), path(fasta)
    path db
    path proteins
    path prodigal_tf

    output:
    tuple val(meta), path("${meta.id}/annot.embl")             , emit: embl
    tuple val(meta), path("${meta.id}/annot.faa")               , emit: faa
    tuple val(meta), path("${meta.id}/annot.ffn")               , emit: ffn
    tuple val(meta), path("${meta.id}/annot.fna")               , emit: fna
    tuple val(meta), path("${meta.id}/annot.gbff")              , emit: gbff
    tuple val(meta), path("${meta.id}/annot.gff3")              , emit: gff
    tuple val(meta), path("${meta.id}/annot.hypotheticals.tsv") , emit: hypotheticals_tsv
    tuple val(meta), path("${meta.id}/annot.hypotheticals.faa") , emit: hypotheticals_faa
    tuple val(meta), path("${meta.id}/annot.tsv")               , emit: tsv
    tuple val(meta), path("${meta.id}/annot.txt")               , emit: txt
    path "versions.yml"                                  , emit: versions
    
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    //prefix = task.ext.prefix ?: "${meta.id}"
    def proteins_opt = proteins ? "--proteins ${proteins[0]}" : ""
    def prodigal_tf_in = prodigal_tf ? "--prodigal-tf ${prodigal_tf[0]}" : ""
    prefix = "annot"

    """
    mkdir -p ${meta.id}
    bakta \\
        $fasta \\
        $args \\
        --threads $task.cpus \\
        --prefix $prefix \\
        $proteins_opt \\
        $prodigal_tf_in \\
        --db $db

    mv ${prefix}.* ${meta.id}/

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bakta: \$(echo \$(bakta --version) 2>&1 | cut -f '2' -d ' ')
    END_VERSIONS
    """

    stub:
"""
mkdir -p ${meta.id}
touch ${meta.id}/annot.embl
touch ${meta.id}/annot.faa
touch ${meta.id}/annot.ffn
touch ${meta.id}/annot.fna
touch ${meta.id}/annot.gbff
touch ${meta.id}/annot.gff3
touch ${meta.id}/annot.hypotheticals.tsv
touch ${meta.id}/annot.hypotheticals.faa
touch ${meta.id}/annot.tsv
touch ${meta.id}/annot.txt

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    bakta: stub
END_VERSIONS
"""    
}
