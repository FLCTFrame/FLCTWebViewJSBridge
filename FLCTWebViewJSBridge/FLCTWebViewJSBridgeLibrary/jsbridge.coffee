do(WIN = window , DOC = document)->
	BRIDGE_EVENT = 'FLCTJSBridgeReady'
	class FLCTCommonMessage
		constructor : (initData)->
			@eventName = initData.eventName || ''
			@data = initData.data || null
			@callBackId = initData.callBackId || 0
		messageFormat : ()->
			return{
				'eventName' : @eventName
				'eventData' : @data
				'eventCallBackId' : @callBackId
			}

	class FLCTJSBridge
		_responseUniqueId = 100
		callBackList = {}
		eventList = {}

		CLINET_CALLBACK_EVENTNAME = 'eventCallBack'

		_sendMessage = ( webViewMessage )->
			message = do webViewMessage.messageFormat
			if WIN.__FLCTWebViewsendMessageToClient
				WIN.__FLCTWebViewsendMessageToClient message
			else if webkit and webkit.messageHandlers.FLCTWebViewMessager
				webkit.messageHandlers.FLCTWebViewMessager.postMessage message
			return

		constructor : ()->

		invoke : ( eventName , data , callBack )->
			callBackId = ++_responseUniqueId
			callBackList[callBackId] = callBack
			webviewMessage = new FLCTCommonMessage
				'eventName' : eventName
				'callBackId' : callBackId
				'data' : data
			_sendMessage webviewMessage
			return
		on : ( eventName , handler )->
			if eventName is CLINET_CALLBACK_EVENTNAME
				console.error """
					eventName can't be #{CLINET_CALLBACK_EVENTNAME}
				"""
				return
			if typeof handler isnt 'function'
				console.error """
					type of #{handler} isn't 'function'
				"""
				return
			eventList[eventName] = handler
			return
		_getMessage : ( message )->
			message = JSON.parse message
			console.log message
			clientMessage = new FLCTCommonMessage message
			if clientMessage.eventName isnt CLINET_CALLBACK_EVENTNAME
				# message from client orgin
				if clientMessage.eventName of eventList
					handler = eventList[clientMessage.eventName]
					callBack = (data)->
						webviewMessage = new FLCTCommonMessage
							'eventName' : CLINET_CALLBACK_EVENTNAME
							'callBackId' : clientMessage.callBackId
							'data' : data
						_sendMessage webviewMessage
					handler clientMessage.data,callBack
			else
				# message from client callback
				callBack = callBackList[clientMessage.callBackId]
				callBack clientMessage.data
				delete callBackList[clientMessage.callBackId]
	WIN.FLCTJSBridge = new FLCTJSBridge()


	readyEvent = DOC.createEvent 'HTMLEvents'
	readyEvent.initEvent BRIDGE_EVENT
	readyEvent.bridge = FLCTJSBridge
	DOC.dispatchEvent readyEvent


