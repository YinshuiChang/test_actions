#!/bin/bash -ue
export MPLCONFIGDIR=$PWD/matplotlib_cache
mkdir -p $MPLCONFIGDIR

segmentation_metrics.py run --path_ref ref.tif --path_list_seg "label_removed_10.tif label_removed_20.tif label_removed_50.tif" --list_metrics "DiceMetric MeanIoU GeneralizedDiceScore HausdorffDistanceMetric SurfaceDistanceMetric SurfaceDiceMetric MSEMetric MAEMetric RMSEMetric PSNRMetric sgm_dice sgm_jaccard sgm_precision sgm_recall sgm_fpr sgm_fnr sgm_hd sgm_msd sgm_stdsd" 

cat <<-END_VERSIONS > versions.yml
IMAGESEGMENTATIONMETRICS:
    seg-metrics: $(segmentation_metrics.py version)
END_VERSIONS
