import groovy.json.JsonGenerator
import groovy.json.JsonGenerator.Converter

nextflow.enable.dsl=2

// comes from nf-test to store json files
params.nf_test_output  = ""

// include dependencies


// include test process
include { IMAGESEGMENTATIONMETRICS } from '/lustre/scratch127/cellgen/cellgeni/yc6/modules/modules/nf-core/imagesegmentationmetrics/tests/../main.nf'

// define custom rules for JSON that will be generated.
def jsonOutput =
    new JsonGenerator.Options()
        .addConverter(Path) { value -> value.toAbsolutePath().toString() } // Custom converter for Path. Only filename
        .build()

def jsonWorkflowOutput = new JsonGenerator.Options().excludeNulls().build()


workflow {

    // run dependencies
    

    // process mapping
    def input = []
    
                input[0] = [
                    "meta",
                    file(params.modules_testdata_base_path + 'ref.tif'),
                    [file(params.modules_testdata_base_path + 'label_removed_10.tif'),
                        file(params.modules_testdata_base_path + 'label_removed_20.tif'),
                        file(params.modules_testdata_base_path + 'label_removed_50.tif')
                    ],
                    "DiceMetric MeanIoU GeneralizedDiceScore HausdorffDistanceMetric SurfaceDistanceMetric SurfaceDiceMetric MSEMetric MAEMetric RMSEMetric PSNRMetric sgm_dice sgm_jaccard sgm_precision sgm_recall sgm_fpr sgm_fnr sgm_hd sgm_msd sgm_stdsd"
                ]
                
    //----

    //run process
    IMAGESEGMENTATIONMETRICS(*input)

    if (IMAGESEGMENTATIONMETRICS.output){

        // consumes all named output channels and stores items in a json file
        for (def name in IMAGESEGMENTATIONMETRICS.out.getNames()) {
            serializeChannel(name, IMAGESEGMENTATIONMETRICS.out.getProperty(name), jsonOutput)
        }	  
      
        // consumes all unnamed output channels and stores items in a json file
        def array = IMAGESEGMENTATIONMETRICS.out as Object[]
        for (def i = 0; i < array.length ; i++) {
            serializeChannel(i, array[i], jsonOutput)
        }    	

    }
  
}

def serializeChannel(name, channel, jsonOutput) {
    def _name = name
    def list = [ ]
    channel.subscribe(
        onNext: {
            list.add(it)
        },
        onComplete: {
              def map = new HashMap()
              map[_name] = list
              def filename = "${params.nf_test_output}/output_${_name}.json"
              new File(filename).text = jsonOutput.toJson(map)		  		
        } 
    )
}


workflow.onComplete {

    def result = [
        success: workflow.success,
        exitStatus: workflow.exitStatus,
        errorMessage: workflow.errorMessage,
        errorReport: workflow.errorReport
    ]
    new File("${params.nf_test_output}/workflow.json").text = jsonWorkflowOutput.toJson(result)
    
}
