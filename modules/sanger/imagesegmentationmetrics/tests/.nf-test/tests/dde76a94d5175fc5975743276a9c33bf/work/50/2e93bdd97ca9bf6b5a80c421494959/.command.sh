#!/bin/bash -ue
touch meta.csv

cat <<-END_VERSIONS > versions.yml
IMAGESEGMENTATIONMETRICS:
    seg-metrics: $(segmentation_metrics.py version)

END_VERSIONS
