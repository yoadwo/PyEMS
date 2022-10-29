from pyems import DestinationType, AcknowledgeMode
import unittest, pyems
    
class pyemsTestCase(unittest.TestCase):
    def setUp(self):
        self.conn = pyems.Connection("tcp://7222","admin","admin123","UnitTest")

    def tearDown(self):
        self.conn.close()
        
    def testQueuePublishSubscribeText(self):
        try:
            sess = self.conn.createSession()
            dest = pyems.Destination("UNIT.TEST.TEXT", DestinationType.TIBEMS_QUEUE)
            prod = sess.createProducer(dest)
            cons = sess.createConsumer(dest)
            msg = pyems.Message("this is a test")
            self.conn.start()
            prod.sendMessage(msg)
            _msg = cons.receiveMessage()
        finally:
            prod.close()
            cons.close()
            sess.close()
            self.conn.stop()
        self.assertEqual(str(_msg), "this is a test")
        
    def testQueuePublishSubscribeMap(self):
        try:
            sess = self.conn.createSession()
            dest = pyems.Destination("UNIT.TEST.MAP", DestinationType.TIBEMS_QUEUE)
            prod = sess.createProducer(dest)
            cons = sess.createConsumer(dest)
            sentDict = {"key1":"val1", "key2":"val2"}
            msg = pyems.Message(sentDict)
            self.conn.start()
            prod.sendMessage(msg)
            _msg = cons.receiveMessage()
            receivedDict = _msg.getNaturalType()
            print "sent: " + str(sentDict)
            print "received: " + str(receivedDict)
        finally:
            prod.close()
            cons.close()
            sess.close()
            self.conn.stop()
        self.assertEqual(sentDict["key1"],receivedDict["key1"])

    #def testQueueRequest(self):
	#return
	#sess = self.conn.createSession()
        #dest = pyems.Destination("reqrep", DestinationType.TIBEMS_QUEUE)
        #req = sess.createRequestor(dest)
        #msg = pyems.Message("foo")
        #self.conn.start()
        #reply = req.request(msg)
        #print str(reply)
        #req.close()
        #del req, dest
        #sess.close()
        #self.conn.stop()
        #
def runTests():
    suite = unittest.makeSuite(pyemsTestCase, "test")
    runner = unittest.TextTestRunner(verbosity=1)
    runner.run(suite)
    
if __name__ == "__main__":
    runTests()
