({
    doInit : function(component, event, helper) {
        helper.loadInitDate(component, event, helper);
        //component.find('inputFromAddress').focus();

        window.addEventListener("message", function(event) {
            var vfOrigin = component.get("v.vfUrl");
            if (event.origin !== vfOrigin) {
                return;
            }
              component.set("v.emailMessage.Body__c", event.data);
        }, false);
    },

    openPreviewModal: function(component, event) {
        component.set("v.openModal", true);
    },

    getTemplateCon: function (component, event, helper) {
        helper.getContactById(component, event, helper);
        helper.getTemplateByContact(component, event, helper);
    },

    closePreviewModal: function(component, event, helper) {
        component.set("v.openModal", false);
    },

    saveEmail: function(component, event, helper) {
        helper.saveSendEmail(component, event, helper, 'Draft');
    },

    openQuickTextModal: function(component, event) {
        component.set("v.openQuickText", true);
    },

    sendEmail: function(component, event, helper) {
        if (helper.isValid(component, event, helper)) {
        	helper.saveSendEmail(component, event, helper, 'Sent');
        }
    },

    addQuickText: function(component, event, helper){
        component.set("v.openQuickText", false);
        if(event.getParam("isClosed") == "true"){
            return;
        }
        var emailMessage = component.get("v.emailMessage");
        var quickText = event.getParam("quick_text");
        quickText = quickText.replace(/(?:\r\n|\r|\n)/g, '<br>');
        emailMessage.Body__c = (emailMessage.Body__c ? emailMessage.Body__c : '') + "\n" + quickText;
        component.set("v.emailMessage.Body__c", emailMessage.Body__c)
        helper.setBodyToVf(component, event, helper);
    },

    attachmentsLog: function(component, event, helper){
        component.set("v.attachments", event.getParam("encodedFilesInfo"));
    },

    deleteAttachmentClient: function(component, event, helper){
        helper.deleteAttach(component, event, helper);
    }
})