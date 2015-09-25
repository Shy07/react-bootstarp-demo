
Date.prototype.format = (fmt) ->
    o = {
      "M+": this.getMonth() + 1
      "d+": this.getDate()
      "h+": this.getHours()
      "m+": this.getMinutes()
      "s+": this.getSeconds()
      "q+": Math.floor((this.getMonth() + 3) / 3)
      "S": this.getMilliseconds()
    }
    fmt = fmt.replace RegExp.$1, (this.getFullYear() + "").substr 4 - RegExp.$1.length if /(y+)/.test fmt
    for k, v of o
      if new RegExp("(" + k + ")").test fmt
        fmt = fmt.replace RegExp.$1, if RegExp.$1.length == 1 then v else ("00" + v).substr ("" + v).length
    fmt

colorList = [
  '46D6FE'
  'FC85D0'
  'EFFC83'
  'FB3C42'
  '9A81FE'
  '85FB5C'
]

window.userData =
  name:'Visitor'
  color:5

ChatPanelHeader = React.createClass
  render: ->
    that = this.props.that
    listNode = this.props.datas.map((li, index) ->
      if li.class
        <li key={index} className={li.class} />
      else
        <li key={index}>
          <a href={li.href} onClick={if li.click then li.click else null}>
            <i className={li.icon}></i> {li.text}
          </a>
        </li>
    )
    <div className="panel-heading">
      <i className="fa fa-comments fa-fw"></i> Chat
      <div className="btn-group pull-right">
        <button type="button" className="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown">
          <i className="fa fa-chevron-down"></i>
        </button>
        <ul className="dropdown-menu slidedown">
          {listNode}
        </ul>
      </div>
    </div>

ChatPanelFooter = React.createClass
  handleSubmit: (e) ->
    e.preventDefault()
    text = React.findDOMNode(this.refs.text).value.trim()
    return unless text
    this.props.onMsgSubmit text:text, time:new Date().getTime()
    React.findDOMNode(this.refs.text).value = '';

  render: ->
    <div className="panel-footer">
      <form className="input-group" onSubmit={this.handleSubmit}>
        <input type="text" className="form-control input-sm" placeholder="Type your message here..." ref="text" />
        <span className="input-group-btn">
          <button type="submit" className="btn btn-warning btn-sm">
            Send
          </button>
        </span>
      </form>
    </div>

ChatPanelBody = React.createClass
  componentDidUpdate: ->
    return unless this.props.datas.length > 0
    $(React.findDOMNode this).animate scrollTop: $(React.findDOMNode this.refs['ul']).height(), 800

  render: ->
    chatNode = this.props.datas.map((message, index) ->
      return if index == 0
      isUserSelf = userData.name == message.sender
      <li key={index} className={"clearfix left"}>
        <span className={"chat-img pull-left"}>
          <div className={"div-circle-50"}
            style={backgroundColor: "##{colorList[message.color]}"}>
            {message.sender[0]}
          </div>
        </span>
        <div className="chat-body clearfix">
          <div className="header">
            <strong className="primary-font">{message.sender}</strong>
            <small className="pull-right text-muted">
              <i className="fa fa-clock-o fa-fw"></i> {new Date(parseInt(message.time)).format 'yyyy-MM-dd'}
            </small>
          </div>
          <p>
            {message.text}
          </p>
        </div>
      </li>
    )
    <div className="panel-body">
      <ul className="chat" ref="ul">
        {chatNode}
      </ul>
    </div>

ColorChoose = React.createClass
  handleChoose: (i) ->
    this.setState color: i

  getInitialState: -> color: null

  render: ->
    checked = <i className="fa fa-check fa-fw" />
    aList =
      for i in [0...5]
        <a key={i} href="javascript:;" onClick={this.handleChoose.bind this, i}
          style={backgroundColor: "##{colorList[i]}"}
          className={"col-sm-offset-1 col-sm-1 div-circle-50 #{
            'border-gray' if this.state.color == i
          }"}>
          {checked if this.state.color == i}
        </a>

    <div style={height:'50px'}>
      {aList}
    </div>

ChatPanel = React.createClass

  chatMenuData: [
    {
      href: "javascript:;"
      icon: "fa fa-user fa-fw"
      text: 'Setting'
      click: -> window.chatPanel.openModal()
    }
  ]

  loadMsgsFromServer: ->
    $.ajax
      url: this.props.url
      dataType: 'json'
      cache: false
      success: ((data) ->
        return if data[0].time == '0'
        if this.state.data.length > 0 && data[0].time == this.state.data[0].time
          return
        this.setState data: data
      ).bind this
      error: ((xhr, status, err) ->
        console.error this.props.url, status, err.toString()
      ).bind this

  handleMsgSubmit: (message) ->
    message['sender']= userData.name
    message['color']= userData.color
    messages = this.state.data
    newMessages = messages.concat [message]
    this.setState data: newMessages
    $.ajax
      url: this.props.url
      dataType: 'json'
      type: 'POST'
      data: message
      success: ((data) ->
        this.setState data: data
      ).bind this
      error: ((xhr, status, err) ->
        console.error this.props.url, status, err.toString()
      ).bind this

  getInitialState: ->
    window.chatPanel = this
    data: []
    firstLoad: true

  openModal: -> this.refs.modal.open()
  closeModal: ->
    name = React.findDOMNode(this.refs.userName).value.trim()
    window.userData.name = name unless name == ''
    color = this.refs.color.state.color
    window.userData.color = color unless color == null
    if this.state.firstLoad
      this.state.firstLoad = false
      this.loadMsgsFromServer()
      setInterval this.loadMsgsFromServer, this.props.pollInterval
    this.refs.modal.close()

  componentDidMount: ->
    this.openModal()

  componentWillUnmount: ->
    window.chatPanel = null

  render: ->
    <div className="chat-panel panel panel-default">
      <ChatPanelHeader datas={this.chatMenuData} that={this}/>
      <ChatPanelBody datas={this.state.data} />
      <ChatPanelFooter onMsgSubmit={this.handleMsgSubmit}/>
      <BootstrapModal
        ref="modal"
        confirm="OK"
        onConfirm={this.closeModal}
        title="Hello,">
        <p>Good day, visitor.</p>
        <p>This demo is built with <strong>Facebook React</strong> and <strong>Twitter Bootstrap</strong>.<br/>
        You can chat with other visitors of this demo at the same time.<br/>
        Anyway, just try, and you will konw what's it.</p>
        <p>Enjoy!</p>
        <hr />
        <p>Now, let's do some option.</p>
        <input className="form-control" ref="userName" placeholder="Input your nickname here" />
        <p><br/>And, which color do you prefer?</p>
        <ColorChoose ref="color"/>
      </BootstrapModal>
    </div>

BootstrapButton = React.createClass
  render: ->
    <a {...this.props}
      href="javascript:;"
      role="button"
      className={(this.props.className || '') + ' btn'} />

BootstrapModal = React.createClass
  componentDidMount: ->
    $(React.findDOMNode this).modal backdrop: 'static', keyboard: false, show: false
  componentWillUnmount: -> $(React.findDOMNode this).off 'hidden', this.handleHidden
  close: -> $(React.findDOMNode this).modal 'hide'
  open: -> $(React.findDOMNode this).modal 'show'
  handleCancel: -> this.props.onCancel() if this.props.onCancel
  handleConfirm: -> this.props.onConfirm() if this.props.onConfirm

  render: ->
    confirmButton = null
    cancelButton = null
    closeButton = null
    confirmButton = (
      <BootstrapButton
        onClick={this.handleConfirm}
        className="btn-primary">
        {this.props.confirm}
      </BootstrapButton>
    ) if this.props.confirm
    cancelButton = (
      <BootstrapButton onClick={this.handleCancel} className="btn-default">
        {this.props.cancel}
      </BootstrapButton>
    ) if this.props.cancel
    closeButton = (
      <button type="button" className="close" onClick={this.handleCancel}>
        &times;
      </button>
    ) if this.props.cancel
    <div className="modal fade">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h3>{this.props.title}</h3>
          </div>
          <div className="modal-body">
            {this.props.children}
          </div>
          <div className="modal-footer">
            {cancelButton}
            {confirmButton}
          </div>
        </div>
      </div>
    </div>


React.render(
  <ChatPanel url="messages.json" pollInterval={2000} />
  ,document.getElementById 'content'
)
