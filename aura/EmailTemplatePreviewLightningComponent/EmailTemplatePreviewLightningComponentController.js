({
    doInit: function(component, event, helper) {
        helper.replaceString(component, event, helper);
    },
    
    closeModel: function(component, event, helper) {
        var closeEvent = component.getEvent("closePreviewEvent");
        closeEvent.setParam("openModal", false);
        closeEvent.fire();
    }
})