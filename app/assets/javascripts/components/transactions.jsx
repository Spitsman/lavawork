var Transactions = React.createClass({
  getInitialState: function(){
    return {
      commission_percent: this.props.commission_percent,
      amount: null,
      total: null,
      commission: null,
      receiver: this.props.users[0].id,
      transactions: this.props.transactions,
      error: false
    }
  },
  onAmountChange: function(e){
    var amount = Number(e.target.value);
    var commission = amount * this.state.commission_percent/100;
    var total = amount + commission;
    return this.setState({ amount, commission, total });
  },
  onFormSubmit: function(e) {
    e.preventDefault();
    var self = this;
    $.ajax({
      method: "POST",
      url: "/my/transactions",
      data: {
        receiver: this.state.receiver,
        amount: this.state.amount,
      },
      success: function (data) {
        console.log(data);
        var transactions = self.state.transactions.slice();
        transactions.unshift(data.transaction);
        self.setState({
          ...self.state,
          amount: '',
          total: '',
          commission: '',
          error: false,
          transactions
        });
      },
      error: function(data) {
        console.log(data);
        self.setState({
          ...self.state,
          error: data.responseJSON.message
        })
      }
    });
  },
  buttonDisabled: function() {
    return this.state.amount == 0
  },
  onInputChange: function(key, event) {
    this.setState({[key]: event.target.value});
  },
  renderForm: function(){
    var users = this.props.users.map(function(user) {
      return <option value={user.id}>{user.name}</option>
    })
    return (
      <div className='box box-success'>
        <div className='box-header with-border'>
          <h3 className='box-title'>Новая транзакция</h3>
        </div>
        <div className='box-body'>
          <div className='row'>
            <form onSubmit={this.onFormSubmit}>
              <div className='col-xs-3'>
                <select name='receiver' class='form-control' placeholder='Получатель' value={this.state.receiver} onChange={this.onInputChange.bind(this, 'receiver')}>
                  {users}
                </select>
              </div>
              <div className='col-xs-3'>
                <input type='number' name='amount' class='form-control' placeholder='Сумма' onChange={this.onAmountChange} value={this.state.amount}/>
              </div>
              <div className='col-xs-2'>
                <input name='commission' type='number' class='form-control' placeholder='Комиссия' value={this.state.commission} disabled />
              </div>
              <div className='col-xs-2'>
                <input name='total' type='number' class='form-control' placeholder='Всего' value={this.state.total} disabled />
              </div>
              <div className='col-xs-2'>
                <button type='submit' className='btn btn-success btn-xs' disabled={this.buttonDisabled()} >Создать</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    )
  },
  renderErrorBlock: function() {
    if (this.state.error) {
      return (
        <div className="alert alert-danger" role="alert">
          <strong>Ошибка!</strong>{' ' + this.state.error}
        </div>
      )
    } else {
      return false;
    }
  },
  render() {
    var transactions = this.state.transactions.map(function(transaction, index){
      return (
        <tr key={index}>
          <td>{transaction.receiver}</td>
          <td>{transaction.amount}</td>
          <td>{transaction.commission}</td>
          <td>{transaction.created_at}</td>
        </tr>
      )
    });

    return(
      <div>
      {this.renderErrorBlock()}
      {this.renderForm()}
      <div className='box box-primary'>
        <div className='nav-tabs-custom'>
          <div className='tab-content'>
            <div className='tab-pane active'>
              <table className='table table-bproducted table-hover dataTable'>
                <thead>
                  <tr>
                    <th>Кому</th>
                    <th>Лава</th>
                    <th>Комиссия</th>
                    <th>Дата</th>
                  </tr>
                </thead>
                <tbody>
                  {transactions}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    )
  }
})

module.exports = Transactions;
