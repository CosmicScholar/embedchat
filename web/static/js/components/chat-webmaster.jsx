import React from 'react';
import Paper from 'material-ui/lib/paper';

import UserLists from './user-lists';
import ListMessages from './list-messages';
import MessageForm from './message-form';

const dataMoc = [
  { id: 1, name: 'abc', text: 'helll', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
  { id: 2, name: 'aghh', text: 'fsadf lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
  { id: 3, name: 'dds', text: 'abcd lkj sdlf ', createdAt: 'Thu, 11 Feb 2016 14:54:07 GMT' },
];

const userMoc = [
  { uid: 'ADAF9924-EEC8-467A-A822-AA4DB2887814' },
  { uid: 'EDAF9924-EEC8-467A-A822-AA4DB2887814' },
];

function mergeDup(arr) {
  return arr.reduce((prev, current, index) => {
    const newArr = prev;
    if (!(current.uid in prev.keys)) {
      newArr.keys[current.uid] = index;
      newArr.result.push(current);
    } else {
      newArr.result[newArr.keys[current.uid]] = current;
    }
    return prev;
  }, { result: [], keys: {} }).result;
}

class ChatWebmaster extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      data: dataMoc,
      onlineUsers: [],
      offlineUsers: userMoc,
    };
    this.handleInputMessage = this.handleInputMessage.bind(this);
    this.handleReceiveMessage = this.handleReceiveMessage.bind(this);
    this.handleSelectUser = this.handleSelectUser.bind(this);
    this.handleUserJoin = this.handleUserJoin.bind(this);
    this.handleUserLeft = this.handleUserLeft.bind(this);
  }

  componentDidMount() {
    this.props.room.onMessage((msg) => {
      this.handleReceiveMessage(msg);
    });
    this.props.room.onUserJoin((user) => {
      this.handleUserJoin(user);
    });
    this.props.room.onUserLeft((user) => {
      this.handleUserLeft(user);
    });
    this.props.room.join();
  }

  handleInputMessage(inputText) {
    console.log(inputText);
  }

  handleReceiveMessage(msg) {
    console.log(msg);
  }

  handleUserJoin(user) {
    if (this.props.room.isSelf(user.distinct_id)) {
      return;
    }
    const users = this.state.onlineUsers;
    const newUser = { uid: user.distinct_id };
    const newUsers = mergeDup(users.concat([newUser]));
    this.setState({ onlineUsers: newUsers });
  }

  handleUserLeft(user) {
    console.log(user);
  }

  handleSelectUser(name) {
    console.log(name);
  }

  render() {
    return (
      <div className="row">
        <div className="col-xs-3">
          <Paper zDepth={1}>
            <UserLists
              onlineUsers={this.state.onlineUsers}
              offlineUsers={this.state.offlineUsers}
              onUserSelected={this.handleSelectUser}
            />
          </Paper>
        </div>
        <div className="col-xs-9">
          <Paper zDepth={1}>
            <ListMessages messages={this.state.data} />
            <MessageForm onInputMessage={this.handleInputMessage} />
          </Paper>
        </div>
      </div>
    );
  }
}

ChatWebmaster.propTypes = {
  room: React.PropTypes.object.isRequired,
};

export default ChatWebmaster;
