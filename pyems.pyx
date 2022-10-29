class AcknowledgeMode:
    TIBEMS_AUTO_ACKNOWLEDGE = 1
        
class DestinationType:
    TIBEMS_QUEUE = 1
    TIBEMS_TOPIC = 2
    
cdef class Connection
cdef class Session
cdef class Destination
cdef class Producer
cdef class Consumer
cdef class Requestor
cdef class Message

cdef Session initSession(tibemsSession c_Session):
    cdef Session py_Session
    py_Session = Session()
    py_Session.c_Session = c_Session
    return py_Session

cdef Producer initProducer(tibemsMsgProducer c_Producer):
    cdef Producer py_Producer
    py_Producer = Producer()
    py_Producer.c_Producer = c_Producer
    return py_Producer

cdef Consumer initConsumer(tibemsMsgConsumer c_Consumer):
    cdef Consumer py_Consumer
    py_Consumer = Consumer()
    py_Consumer.c_Consumer = c_Consumer
    return py_Consumer

cdef Requestor initRequestor(tibemsMsgRequestor c_Requestor):
    cdef Requestor py_Requestor
    py_Requestor = Requestor()
    py_Requestor.c_Requestor = c_Requestor
    return py_Requestor

cdef Message initMessage(tibemsMsg c_Message):
    cdef Message py_Message
    py_Message = Message()
    py_Message.c_Message = c_Message
    return py_Message

class EMSError(Exception):
    def __init__(self,value):
        self.value = value
    def __str__(self):
        return repr(self.value)
    
cdef class Connection:
    cdef tibemsConnection c_Connection
    
    def __init__(self, server, username, password, clientId = ""):
        cdef tibems_status status
        status = tibemsConnection_Create(&self.c_Connection, server, clientId, username, password)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        
    def __dealloc__(self):
        if self.c_Connection != NULL:
            status = tibemsConnection_Close(self.c_Connection)
        
    def close(self):
        cdef tibems_status status
        status = tibemsConnection_Close(self.c_Connection)
        self.c_Connection = NULL
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        
    def start(self):
        cdef tibems_status status
        status = tibemsConnection_Start(self.c_Connection)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        
    def stop(self):
        cdef tibems_status status
        status = tibemsConnection_Stop(self.c_Connection)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        
    def createSession(self, ackMode = TIBEMS_AUTO_ACKNOWLEDGE):
        cdef tibemsSession c_Session
        cdef tibems_status status
        status = tibemsConnection_CreateSession(self.c_Connection, &c_Session, TIBEMS_FALSE, ackMode)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        return initSession(c_Session)
    
cdef class Destination:
    cdef tibemsDestination c_Destination
    
    def __init__(self, destinationName, destinationType = DestinationType.TIBEMS_QUEUE):
        cdef tibems_status status
        status = tibemsDestination_Create(&self.c_Destination, destinationType, destinationName)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        
    def __dealloc__(self):
        cdef tibems_status status
        status = tibemsDestination_Destroy(self.c_Destination)
    
cdef class Session:
    cdef tibemsSession c_Session
        
    def __dealloc__(self):
        if self.c_Session != NULL:
            self.close()
    
    def close(self):
        cdef tibems_status status
        status = tibemsSession_Close(self.c_Session)
        self.c_Session = NULL
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        
    def createProducer(self, Destination py_Destination):
        cdef tibemsMsgProducer c_Producer
        cdef tibems_status status
        status = tibemsSession_CreateProducer(self.c_Session, &c_Producer, py_Destination.c_Destination)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        return initProducer(c_Producer)
    
    def createConsumer(self, Destination py_Destination):
        cdef tibemsMsgConsumer c_Consumer
        cdef tibems_status status
        status = tibemsSession_CreateConsumer(self.c_Session, &c_Consumer, py_Destination.c_Destination, NULL, TIBEMS_FALSE)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        return initConsumer(c_Consumer)

    def createRequestor(self, Destination py_Destination):
        cdef tibemsMsgRequestor c_Requestor
        cdef tibems_status status
        status = tibemsQueueRequestor_Create(self.c_Session, &c_Requestor, py_Destination.c_Destination)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        return initRequestor(c_Requestor)

cdef class Producer:
    cdef tibemsMsgProducer c_Producer
        
    def __dealloc__(self):
        if NULL != self.c_Producer:
            tibemsMsgProducer_Close(self.c_Producer)

    def close(self):
        cdef tibems_status status
        status = tibemsMsgProducer_Close(self.c_Producer)
        self.c_Producer = NULL
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
       
    def sendMessage(self, Message py_Message):
        tibemsMsgProducer_Send(self.c_Producer, py_Message.c_Message)
     
cdef class Consumer:
    cdef tibemsMsgConsumer c_Consumer
        
    def __dealloc__(self):
        if NULL != self.c_Consumer:
            tibemsMsgConsumer_Close(self.c_Consumer)
        
    def close(self):
        cdef tibems_status status
        status = tibemsMsgConsumer_Close(self.c_Consumer)
        self.c_Consumer = NULL
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))

    def receiveMessage(self):
        cdef tibemsMsg c_Message
        status = tibemsMsgConsumer_ReceiveTimeout(self.c_Consumer, &c_Message, 1000)
        return initMessage(c_Message)
   
cdef class Requestor:
    cdef tibemsMsgRequestor c_Requestor

    def __dealloc__(self):
        if NULL != self.c_Requestor:
            tibemsMsgRequestor_Close(self.c_Requestor)

    def close(self):
        cdef tibems_status status
        status = tibemsMsgRequestor_Close(self.c_Requestor)
        self.c_Requestor = NULL
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))

    def request(self, Message py_Message):
        cdef tibemsMsg c_Reply
        status = tibemsMsgRequestor_Request(self.c_Requestor, py_Message.c_Message, &c_Reply)
        return initMessage(c_Reply)

cdef class Message:
    cdef tibemsMsg c_Message
    
    def __init__(self, message=None):
        if message is not None:
            if type(message) is dict:
                tibemsMapMsg_Create(&self.c_Message)
                for key, value in message.iteritems():
                    tibemsMapMsg_SetString(self.c_Message, key, value)
            else:
                tibemsTextMsg_Create(&self.c_Message)
                tibemsTextMsg_SetText(self.c_Message, message)
            
    def __dealloc__(self):
        tibemsMsg_Destroy(self.c_Message)
        
    def __str__(self):
        cdef char* _msg
        tibemsTextMsg_GetText(self.c_Message, &_msg)
        return _msg
    
    def __repr__(self):
        return self.__str__()
    
    def getNaturalType(self):
        cdef tibems_status status
        cdef char* name
        cdef char* value
        cdef tibemsMsgEnum enum
        msgMap = {}
        status = tibemsMapMsg_GetMapNames(self.c_Message,&enum)
        if status != TIBEMS_OK:
            raise EMSError(tibemsStatus_GetText(status))
        while(tibemsMsgEnum_GetNextName(enum,&name) == TIBEMS_OK):
            status = tibemsMapMsg_GetString(self.c_Message,name,&value)
            if status != TIBEMS_OK:
                raise EMSError(tibemsStatus_GetText(status))
            msgMap[name] = value
        return msgMap
