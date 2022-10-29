cdef extern from "tibems/tibems.h":
    pass
   
cdef extern from "tibems/status.h":
    ctypedef enum tibems_status:
        TIBEMS_OK = 0
    char* tibemsStatus_GetText(tibems_status status)

cdef extern from "tibems/types.h":  
    ctypedef enum tibems_bool:
        TIBEMS_FALSE  = 0
        TIBEMS_TRUE   = 1
    ctypedef enum tibemsAcknowledgeMode:
        TIBEMS_AUTO_ACKNOWLEDGE                     = 1
        TIBEMS_CLIENT_ACKNOWLEDGE                   = 2
        TIBEMS_DUPS_OK_ACKNOWLEDGE                  = 3
        TIBEMS_NO_ACKNOWLEDGE                       = 22
        TIBEMS_EXPLICIT_CLIENT_ACKNOWLEDGE          = 23
        TIBEMS_EXPLICIT_CLIENT_DUPS_OK_ACKNOWLEDGE  = 24
    ctypedef enum tibemsDestinationType:
        TIBEMS_UNKNOWN                              = 0
        TIBEMS_QUEUE                                = 1
        TIBEMS_TOPIC                                = 2
        TIBEMS_DEST_UNDEFINED                       = 256   
    struct __tibemsConnection:
        pass
    struct __tibemsSession:
        pass
    struct __tibemsDestination:
        pass
    struct __tibemsMsg:
        pass
    struct __tibemsMsgEnum:
        pass
    struct __tibemsMsgProducer:
        pass
    struct __tibemsMsgConsumer:
        pass
    struct __tibemsMsgRequestor:
        pass

ctypedef __tibemsConnection* tibemsConnection
ctypedef __tibemsSession* tibemsSession
ctypedef __tibemsSession* tibemsQueueSession
ctypedef __tibemsDestination* tibemsDestination
ctypedef __tibemsDestination* tibemsQueue
ctypedef __tibemsMsgProducer* tibemsMsgProducer
ctypedef __tibemsMsgConsumer* tibemsMsgConsumer
ctypedef __tibemsMsgRequestor* tibemsMsgRequestor
ctypedef __tibemsMsg* tibemsMsg
ctypedef __tibemsMsg* tibemsTextMsg
ctypedef __tibemsMsg* tibemsMapMsg
ctypedef __tibemsMsgEnum* tibemsMsgEnum
ctypedef long tibems_long

cdef extern from "tibems/conn.h":
    tibems_status tibemsConnection_Create(tibemsConnection* connection,
                                          char*             brokerURL,
                                          char*             clientId,
                                          char*             username,
                                          char*             password)
    tibems_status tibemsConnection_CreateSession(tibemsConnection      connection,
                                                 tibemsSession*        session,
                                                 tibems_bool           transacted,
                                                 tibemsAcknowledgeMode acknowledgeMode)
    tibems_status tibemsConnection_Start(tibemsConnection connection)
    tibems_status tibemsConnection_Stop(tibemsConnection connection)
    tibems_status tibemsConnection_Close(tibemsConnection connection)
    
cdef extern from "tibems/dest.h":
    tibems_status tibemsDestination_Create(tibemsDestination*    destination,
                                           tibemsDestinationType type,
                                           char*                 name)
    tibems_status tibemsDestination_Destroy(tibemsDestination    destination)
    
cdef extern from "tibems/sess.h":
    tibems_status tibemsSession_CreateProducer(tibemsSession      session,
                                               tibemsMsgProducer* producer,
                                               tibemsDestination  destination)
    tibems_status tibemsSession_CreateConsumer(tibemsSession      session,
                                               tibemsMsgConsumer* consumer,
                                               tibemsDestination  destination,
                                               char*              optionalSelector,
                                               tibems_bool        noLocal)
    tibems_status tibemsSession_Close(tibemsSession session)
    
cdef extern from "tibems/msgprod.h":
    tibems_status tibemsMsgProducer_Send(tibemsMsgProducer msgProducer,
                                         tibemsMsg         msg)
    tibems_status tibemsMsgProducer_Close(tibemsMsgProducer msgProducer)
    
cdef extern from "tibems/msgcons.h":
    tibems_status tibemsMsgConsumer_ReceiveTimeout(tibemsMsgConsumer msgConsumer,
                                                   tibemsMsg*        msg,
                                                   tibems_long       timeout)
    tibems_status tibemsMsgConsumer_Close(tibemsMsgConsumer msgConsumer)
   
cdef extern from "tibems/msgreq.h":
    tibems_status tibemsQueueRequestor_Create(tibemsQueueSession     session, tibemsMsgRequestor*    msgRequestor, tibemsQueue   queue)
    tibems_status tibemsMsgRequestor_Request(tibemsMsgRequestor msgRequestor,
                                             tibemsMsg          msgSent,
                                             tibemsMsg*         msgReply)
    tibems_status tibemsMsgRequestor_Close(tibemsMsgRequestor  msgRequestor) 

cdef extern from "tibems/tmsg.h":
    tibems_status tibemsTextMsg_Create(tibemsTextMsg* message)
    tibems_status tibemsTextMsg_SetText(tibemsTextMsg message,
                                        char*         text)
    tibems_status tibemsTextMsg_GetText(tibemsTextMsg message,
                                        char**        text)
                                        
cdef extern from "tibems/mmsg.h":
    tibems_status tibemsMapMsg_Create(tibemsMapMsg* message)
    tibems_status tibemsMapMsg_SetString(tibemsMapMsg message,
                                         char*        name,
                                         char*        value)
    tibems_status tibemsMapMsg_GetMapNames(tibemsMsg      message,
                                           tibemsMsgEnum* enumeration)
    tibems_status tibemsMapMsg_GetString(tibemsMapMsg message,
                                         char*        name,
                                         char**       value)
                                        
cdef extern from "tibems/msg.h":
    tibems_status tibemsMsg_Destroy(tibemsMsg message)
    tibems_status tibemsMsgEnum_GetNextName(tibemsMsgEnum enumeration,
                                            char**        name)
