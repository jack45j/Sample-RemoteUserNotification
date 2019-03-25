# Remote UserNotification/PushKit Sample

A sample for configuring remote UserNotification and PushKit.
Because Callkit was blocked in China. We need to manualy complete call scene through user notification so I put a "notificationType" to figure the type of the payload.

# UserNotification Sample payload

	{
    	"aps": {
        	"content-available": 1,
            "alert": {
            	"title": "Your title here",
                "body": "Your body here"
            },
            "badge": 1,
            "notificationType": notify
        },
    }
    

# PushKit Sample payload
    
    {
        "aps": {
          "content-available": 1,
          "alert": "Your message Here",
          "sound": "default",
          "badge": 1,
          "notificationType": "ring"
	    },  
        "acme": {
          "roomNumber": "this is room number",
          "queueID": "this is queue id",
          "doctorName": "this is doctor name"
        }
    }
     


