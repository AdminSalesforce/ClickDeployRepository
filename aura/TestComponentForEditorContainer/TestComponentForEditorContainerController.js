({
	doInit : function(component) {
        var vfOrigin = "https://" + component.get("v.vfUrl");
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                return;
            }
            component.set("v.messageBody", event.data);
        }, false);
    }
})