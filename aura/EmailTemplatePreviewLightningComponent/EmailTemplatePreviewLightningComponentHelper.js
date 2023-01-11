({
  replaceString: function (component, event, helper) {
    var action = component.get("c.replaceString");
    var stringToReplace = component.get("v.bodyPrev");
    if (stringToReplace == undefined){
        stringToReplace = ' ';
    }
      
    var caseId = component.get("v.caseId");
    var salutations = component.get("v.salutationsPrev");
    action.setParams({strToReplace : stringToReplace, caseId : caseId});
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            component.set("v.PreviewBody", (salutations ? salutations : '') + '<p></p>' + response.getReturnValue());
        }
        if (state === "ERROR") {
            Utils.handleError(component, state, response);
        }
    });
    $A.enqueueAction(action);
  },
})