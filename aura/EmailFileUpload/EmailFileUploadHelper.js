({
  getAttachments : function(component) {
    var action = component.get("c.queryFiles");
    action.setParams({emailId : component.get("v.emailId")});
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
           component.set('v.loaded', true);
           component.set("v.files", response.getReturnValue());
        } else if (state === "ERROR") {
           component.set('v.loaded', true);
           Utils.handleError(component, state, response);
        }
    });
    $A.enqueueAction(action);
  },

  deleteFile : function(component, fileId) {
    component.set('v.loaded', false);
    var action = component.get("c.deleteFile");
    action.setParams({fileId : fileId});
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
           this.getAttachments(component);
        } else if (state === "ERROR") {
           component.set('v.loaded', true);
           Utils.handleError(component, state, response);
        }
    });
    $A.enqueueAction(action);
  },
})