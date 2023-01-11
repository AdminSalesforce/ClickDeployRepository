({
    loadInitDate: function (component, event, helper) {
        var caseId = component.get("v.recordId");

        var action = component.get("c.loadInitDate");
        action.setParams({caseId : caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.accountRec', result.account);
                console.log('Subject ------> '+result.subject);
                component.set('v.emailMessage', result.email);    
                component.set('v.parentMailId', result.parentMailId);
                console.log('parent mail id :' + result.parentMailId);
                //component.set('v.emailMessage.Subject__c', result.subject);
                component.set('v.parentCaseId', result.parentCaseId);
                component.set('v.letterTemplate', result.template);
                component.set('v.selectedRecordId', result.contactId);
                component.set('v.vfUrl', result.vfUrl);
                component.set('v.fromAddressEmail', result.fromAddress);
                component.set('v.isLoaded', true);

                helper.getContactById(component, event, helper);
                window.setTimeout(function() {
                      helper.setBodyToVf(component, event, helper);
                  }, 
                  1000
                );
            } else if (state === "ERROR") {
               Utils.handleError(component, state, response);
            }
        });
        $A.enqueueAction(action);
    },

    getContactById : function (component, event, helper){
        var contactId = component.get("v.selectedRecordId");
        var action = component.get("c.getContactById");
        action.setParams({contactId : contactId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.receiverContact", response.getReturnValue());
            } else if (state === "ERROR") {
                 Utils.handleError(component, state, response);
            }
        });
        $A.enqueueAction(action);
    },

    getTemplateByContact: function (component, event, helper) {

        var contactId = component.get("v.selectedRecordId");

        var action = component.get("c.getLetterTemplateContact");
        action.setParams({contactId : contactId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if ( response.getReturnValue() == null ){
                    var template = {'sObjectType':'Letter_Template__c','Brand__c':' ','Footer__c':' ',
                                    'Header__c':' ','Language__c':' ','Name':' ','Salutation__c':' '};
                    component.set("v.letterTemplate", template);
                 } else {
                    component.set("v.letterTemplate", response.getReturnValue());
                 }
            } else if (state === "ERROR") {
                 Utils.handleError(component, state, response);
            }
        });
        $A.enqueueAction(action);
    },

    setBodyToVf: function (component, event, helper) {
        var body = component.get("v.emailMessage.Body__c");
        var vfOrigin = component.get("v.vfUrl");
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(body, vfOrigin);
    },

    saveSendEmail: function (component, event, helper, status) {
        var action = component.get("c.saveSendEmail");
        var templateId = component.get("v.letterTemplate.Id");
        component.set("v.emailMessage.Letter_Template__c", templateId);
        var contactId = component.get("v.selectedRecordId");
        var parentMailId = component.get("v.parentMailId");
        var caseId = component.get("v.parentCaseId");
        var body = component.get("v.emailMessage.Body__c");
        component.set("v.emailMessage.Body__c", body ? body.replace('\n','') : '');
        component.set("v.emailMessage.Parent_Case__c", caseId);
        component.set("v.emailMessage.Related_To_Contact__c", contactId);
        var emailMessage = component.get("v.emailMessage");
        console.log(emailMessage);
        console.log(status)
        action.setParams({emailStr : JSON.stringify(emailMessage), status : status, parentMailId : parentMailId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                Utils.showToast(
                    'Success!', 
                    'success', 
                    (result.status === 'Send' ? 'The email has been sent successfully.' : 'The email has been saved successfully.')
                );
                
                if ('Send' === result.status) {
                    // email succesfully sent, we need to reset the form
                    component.set('v.emailMessage', result.newEmail);
                    
                    // refresh CKEditor
                    helper.setBodyToVf(component, event, helper);
                }
                
                $A.get("e.force:closeQuickAction").fire();
            } else if (state === "ERROR") {
                Utils.handleError(component, state, response);
            }
        });
        $A.enqueueAction(action);
    },
    
    isValid: function (component, event, helper) {
        if ( !component.get("v.selectedRecordId") ) {
           Utils.showToast("Warning!", "warning", "Please specify recipient before sending email");
           return false;
        } else if ( !component.get("v.emailMessage.Subject__c") ) {
           Utils.showToast("Warning!", "warning", "Please specify subject before sending email");
           return false;
        } else if ( !component.get("v.emailMessage.Body__c") ) {
            console.log(component.get("v.emailMessage.Body__c"));
            debugger;
           Utils.showToast("Warning!", "warning", "Please specify body before sending email");
           return false;
        } else if ( !component.get("v.receiverContact.Email") ) {
           console.log(component.get("v.receiverContact"));
           Utils.showToast("Warning!", "warning", "Please populate email address on Contact");
           return false;
        } else if (helper.checkEmails(component.get("v.emailMessage.Cc_Address__c")) ) {
           Utils.showToast("Warning!", "warning", "Cc: Please enter valid email adresses separated by semicolon");
           return false;
        } else if (helper.checkEmails(component.get("v.emailMessage.Bcc_Address__c")) ) {
           Utils.showToast("Warning!", "warning", "Bcc: Please enter valid email adresses separated by semicolon");
           return false;
        }
        return true;
    },
    checkEmails : function(str) {
        if (str == undefined) 
            return false;
        var regex = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)(\s*;\s*|\s*$))*$/g;
        var found = str.match(regex);
        console.log(found);
        if (found == null) 
            return true;
        else return false;
    }
})