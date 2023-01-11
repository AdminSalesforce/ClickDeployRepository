window.Utils = (function() {
    var getErrorMessage = function(component, state, response) {
        var message = '';
        
        if (state === "INCOMPLETE") {
            return  "No Response From Server";
        }
        
        if (state === "ERROR") {
            var errors = response.getError();
            if (errors) {
                for (var i=0; i < errors.length; i++) {
                    for (var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                        message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j];
                    }
                    if (errors[i].fieldErrors) {
                        for(var fieldError in errors[i].fieldErrors) {
                            var thisFieldError = errors[i].fieldErrors[fieldError];
                            for(var j=0; j < thisFieldError.length; j++) {
                                message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                            }
                        }
                    }
                    if (errors[i].message) {
                        message += (message.length > 0 ? '\n' : '') + errors[i].message;
                    }
                }
            } else {
                message = "Unknown Error";
            }
        } else {
            message = "Unknown Status Error: " + state;
        }
        
        return message;
    };
    
    var handleError = function(component, state, response) {
        var message = getErrorMessage(component, state, response);

        var notifLib = component.find('notifLib');
        this.showNotice(notifLib, 'Error', 'error', message);
    };
    
    var showToast = function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                type: type,
                message: message
            });
            toastEvent.fire();
        }
        // if not running in LEX or SF1, toast is not available - use alert
        else {
            alert(title + ', ' + message);
        }
    };

    var showNotice = function(notifLib, title, type, message) {
        if (notifLib) {
          notifLib.showNotice({
              "variant": "error",
              "header": title,
              "message": message,
              closeCallback: function() {}
          });
        } else {
          this.showToast('Error', 'error', message);
        }
    };
    
    return { // public api
        handleError : handleError,
        showToast : showToast,
        showNotice : showNotice
    };

}());