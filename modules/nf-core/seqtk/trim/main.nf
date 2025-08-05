process SEQTK_TRIM {
    tag "$meta.id"
    label 'process_low'

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.fastq.gz"), emit: reads
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args   = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    printf "%s\\n" $reads | while read f;
    do
        seqtk \\
            trimfq \\
            $args \\
            \$f \\
            | gzip --no-name > ${prefix}_\$(basename \$f)
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        seqtk: \$(echo \$(seqtk 2>&1) | sed 's/^.*Version: //; s/ .*\$//')
    END_VERSIONS
    """
}
