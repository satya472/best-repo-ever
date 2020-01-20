public virtual with sharing class JSONMessage {

    public virtual with sharing class MessageError {
        public String type;
        public String trace;
        public String message;
    }

    public virtual with sharing class APIResponse {

        public String type;
        public Datetime timeNow;
        public Boolean isSuccess;
        public String responseObject;
        public String message;
        public String transactionId;
        public MessageError error;
        public Boolean moreResults = false;

        public Object getResponseAs(Type klass) {
            return JSON.deserialize(responseObject, klass);
        }

    }
}