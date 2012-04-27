/**
 * This class is defined as a data structure for the result of sample code executed. 
 */
global class RestSampleCodeForApiResult {
    /**
     * Identify the processing is success or false.
     */
    global Boolean success { get; set; }
    
    /**
     * The aim is to give any kinds of status 's code with require.
     */
    global String statusCode { get; set; }
    
    /**
     * As a note field but not required, it is used to give a detail for status.
     */
    global String statusMessage { get; set; }
    
    public RestSampleCodeForApiResult() {}
    
    global override String toString() {
        return 'Success: ' + this.success + ', Status Code: ' + this.statusCode + ', Status Message: ' + statusMessage;
    }
}