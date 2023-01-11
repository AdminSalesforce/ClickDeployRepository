({
  doInit : function(component, event, helper) {
    helper.getAttachments(component);
  },

  handleUploadFinished : function (component, event, helper) {
    helper.getAttachments(component);
  },

  handleDeleteFile : function (component, event, helper) {
    var fileId = event.target.id;
    helper.deleteFile(component, fileId);
  },
})