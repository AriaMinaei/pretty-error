module.exports = -> {
	'pretty-error':

		display: 'block'

		marginBottom: 1

	'pretty-error > header':

		display: 'block'

		marginBottom: 1

	'pretty-error > header > kind':

		background: 'red'

		color: 'bright-white'

	'pretty-error > header > colon':

		color: 'grey'

	'pretty-error > header > message':

		color: 'bright-white'

	'pretty-error > trace':

		display: 'block'

	'pretty-error > trace > item':

		display: 'block'

		marginBottom: 1

		marginLeft: 2

		bullet: '"<grey>o</grey>"'

	'pretty-error > trace > item > header':

		display: 'block'

	'pretty-error > trace > item > header > file':

		color: 'bright-yellow'

	'pretty-error > trace > item > header > colon':

		color: 'grey'

	'pretty-error > trace > item > header > line':

		color: 'bright-yellow'

		marginRight: 1

	'pretty-error > trace > item > footer':

		display: 'block'

	'pretty-error > trace > item > footer > addr':

		color: 'grey'
}