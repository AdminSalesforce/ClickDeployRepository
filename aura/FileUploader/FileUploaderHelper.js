({
	handleFilesChange: function (cmp) {
       let files = document.getElementById('file-upload-input-01').files;
       
       let filesArray = cmp.get("v.files");
       let filesDescriprionsArray = cmp.get("v.filesDescription");
      
       let fileDescription = {
           name : "",
           extension : "",
           size : ""
       }

       let exit;
       filesArray.forEach(function(item){
           if (item.name == files[0].name){
               alert("File already uploaded");
               exit = "true"
           }
       });
       if (exit)
           return;

       fileDescription.name = files[0].name.substring(0, files[0].name.indexOf('.'));
       fileDescription.extension = files[0].name.substring(files[0].name.indexOf('.'));
       
       if ( files[0].size < 100000 ) {
           fileDescription.size = " (" + (files[0].size/1000).toFixed(1) + "K)" ;
       } else {
           fileDescription.size = " (" + (files[0].size/1000000).toFixed(1) + "M)" ;
       }

       var sumSize = 0;

       filesArray.forEach( function(item){
           sumSize += item.size;
           console.log(sumSize+"    "+item.size);
       });

       
      
       if ( sumSize+files[0].size > 10000000 ){
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
           "title": "Warning!",
           "message": "File size limit exceeded (10mb)",
           "type" : "warning"
           });
           toastEvent.fire();
       } else { 

           filesDescriprionsArray.unshift(fileDescription);
           filesArray.unshift(files[0]);

           cmp.set("v.files", filesArray);
           cmp.set("v.filesDescription", filesDescriprionsArray);
       
           let encodedFilesInfo = cmp.get("v.encodedFilesInfo");

           var reader = new FileReader();
           reader.readAsDataURL(files[0]);
       
           reader.onload = function () {
               let base64Files = {
                   name : files[0].name,
                   body : reader.result
               }
               encodedFilesInfo.unshift(base64Files);
               cmp.set("v.encodedFilesInfo", encodedFilesInfo);
               var attachmentSenderEvent = cmp.getEvent("attachmentSender");
               attachmentSenderEvent.setParam("encodedFilesInfo", encodedFilesInfo);
               attachmentSenderEvent.fire();
           };
       }

	},
    deleteAttachment : function (cmp, event) {
        let elementToDeleteId = event.target.id;
        let files = cmp.get('v.files');
        let filesDescription = cmp.get('v.filesDescription');
        let encodedFilesInfo = cmp.get('v.encodedFilesInfo');
        let deleteEvent = cmp.getEvent('deleteAttachment');
        console.log(files.length);
        for( var i = 0; i < files.length; i++){ 
            console.log(1432);
            if ( files[i].name == elementToDeleteId) {
                files.splice(i, 1);
                deleteEvent.setParam("attachmentId", files[i].id);
                console.log(2);
            }
            if ( filesDescription[i].name + filesDescription[i].extension == elementToDeleteId) {
                filesDescription.splice(i, 1); 
                deleteEvent.setParam("attachmentId", filesDescription[i].id);
                console.log(3);
            }
            if ( encodedFilesInfo[i].name == elementToDeleteId ){
                files.splice(i,1);
                console.log(4);
            }
        }
        $(event.target).toggleClass("invisible");
        if (deleteEvent.getParam('attachmentId') != '') {
            console.log(5);
            deleteEvent.fire();
        }
    }
})