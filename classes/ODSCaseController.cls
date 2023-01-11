public class ODSCaseController {

    public pagereference downloadAsExcel(){
        PageReference excel = Page.ODSDownloadExcel;
            
            excel.setRedirect(false);
            return excel;
    }
}