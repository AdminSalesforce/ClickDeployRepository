({
   allMatchingQuickText: function(component, event, helper) {
      
      if(component.get("v.contactId") == "" || component.get("v.contactId") == undefined ){
          
      } else { 
          let action = component.get("c.getQuickText");
          action.setParams({
              "contactIdVal" : component.get("v.contactId")
          });
          action.setCallback(this, function(response) {
      
              var state = response.getState();
              if (state === "SUCCESS") {
                  component.set("v.quick_text", response.getReturnValue());
                  component.set("v.searched_quick_text", response.getReturnValue());
              }
              else if (state === "INCOMPLETE") {
              }
              else if (state === "ERROR") {
                  var errors = response.getError();
                  if (errors) {
                      if (errors[0] && errors[0].message) {
                          alert("Error message: " + 
                                   errors[0].message);
                      }
                  } else {
                      alert("Unknown error");
                  }
              }          
          });
          $A.enqueueAction(action);
      }
   }, 
   closeModel : function (component, event, helper) {
       component.set("v.isOpen", "false");
       var event = component.getEvent("quickTextAdding");
       component.set("v.isOpen", "false");
       event.setParams({ "isClosed" : "true" });
       event.fire();
   },
   getContent : function (component, event, helper) {
       let quick_text_arr = component.get("v.quick_text");
       
       quick_text_arr.forEach( function(item) {
           if(item.Name == $(event.target).text()) {
               component.set("v.current_quick_text_content", item.Quick_Text_Message__c);
           }
       });
   },
   getSearchedQuickText : function (component, event, helper) {
       
       component.set("v.current_quick_text_content", "");

       let searched = component.find('enter-search').get('v.value')
       let quickTextArray = component.get("v.quick_text");
       let searchedArray = [];
       if (quickTextArray != null) {
           if ( searched == undefined ){
               component.set("v.searched_quick_text", quickTextArray);
           } else {
               quickTextArray.forEach( function(item){
                   if(item.Name.toUpperCase().includes(searched.toUpperCase())){
                       searchedArray.unshift(item);
                   }
               });
               component.set("v.searched_quick_text", searchedArray);
           }
       }
   },
   addQuickText : function (component, event, helper) {
        
       var event = component.getEvent("quickTextAdding");
       var quickTextContent = component.get("v.current_quick_text_content");
       if ( quickTextContent == undefined ){
           Utils.showToast("Warning!", "warning", "Quick Text is Empty");
       } else {
           component.set("v.isOpen", "false");
           event.setParams({ "quick_text" : quickTextContent });
           event.fire();
       }
   }
})