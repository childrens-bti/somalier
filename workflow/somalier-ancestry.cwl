cwlVersion: v1.2
class: CommandLineTool

label: somalier-ancestry
doc: |
  Run somalier ancestry using a 1000G reference provided as a tar archive.
  The tar is unpacked inside the job, and all *.somalier files are passed
  correctly to somalier ancestry.

baseCommand: [bash, -c]

requirements:
  - class: DockerRequirement
    dockerPull: brentp/somalier:v0.3.1
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: query_somalier.list
        entry: $(inputs.query_somalier.map(function(f) { return f.path; }).join("\n"))

inputs:

  labels:
    type: File
    doc: TSV mapping reference samples to ancestry labels

  reference_tar:
    type: File
    doc: |
      1000 Genomes reference somalier tar file
      (e.g. 1kg.somalier.tar from Zenodo)

  query_somalier:
    type:
      type: array
      items: File
    doc: Query sample *.somalier files

  output_prefix:
    type: string?
    default: somalier
    doc: Output prefix for results

arguments:
  - shellQuote: false
    valueFrom: |
      set -euo pipefail

      echo "Extracting reference Somalier tar..."
      tar -xf "$(inputs.reference_tar.path)"

      echo "Running somalier ancestry..."
      somalier ancestry \
        --labels "$(inputs.labels.path)" \
        --output-prefix "$(inputs.output_prefix)" \
        1kg-somalier/*.somalier \
        ++ \
        query_somalier.list

outputs:

  ancestry_tsv:
    type: File
    doc: TSV with ancestry predictions
    outputBinding:
      glob: "*.somalier-ancestry.tsv"

  ancestry_html:
    type: File
    doc: Interactive HTML PCA plot
    outputBinding:
      glob: "*.somalier-ancestry.html"