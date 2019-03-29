const promptly = require('promptly');
const Table = require('cli-table');

const initKredits = require('./helpers/init_kredits.js');

module.exports = async function(callback) {
  let kredits;
  try {
    kredits = await initKredits(web3);
  } catch(e) {
    callback(e);
    return;
  }

  console.log(`Using Contributor at: ${kredits.Contributor.contract.address}`);


  const table = new Table({
    head: ['ID', 'Account', 'Core?', 'Name']
  })

  let contributors = await kredits.Contributor.all()

  contributors.forEach((c) => {
    table.push([
      c.id.toString(),
      c.account,
      c.isCore,
      `${c.name}`
    ])
  })
  console.log(table.toString())
  callback()
}
