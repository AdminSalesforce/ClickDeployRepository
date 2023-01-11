({
    doInit: function (cmp, event, helper) {
        var files = cmp.get("v.files");
        var filesdesc = cmp.get("v.filesDescription");
        var encoded = cmp.get("v.encodedFilesInfo");
        files.forEach(function(item) {
            encoded.push({name:item.name, body: item.body});
            filesdesc.push({name:item.name.substring(0, item.name.indexOf('.')), extension : item.name.substring(item.name.indexOf('.'))});
        });
        cmp.set("v.filesDescription", filesdesc);
        cmp.set("v.encodedFilesInfo",encoded);
    },
    handleFilesChange : function (cmp, event, helper) {
       helper.handleFilesChange(cmp);
    },
    deleteAttachment : function (cmp, event, helper) {
        helper.deleteAttachment(cmp, event);
    }
})