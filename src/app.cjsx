console.log appSettings
conf = 
    baseUrl: appSettings.static_url
    paths:
        app: 'scripts'
        'react-bootstrap/lib': 'components/react-bootstrap/lib'

require.config conf

require ['jquery', 'react-router', 'react', 'react-bootstrap', 'react-router-bootstrap'], ($, Router, React, RB, RBR) ->
    Project = React.createClass
        contextTypes:
            router: React.PropTypes.func

        getInitialState: -> data: {}, vouchers: null
        componentDidMount: ->
            projectId = @context.router.getCurrentParams().projectId
            $.ajax
                url: "http://localhost:8000/heta/project/#{projectId}/"
                dataType: 'json'
                success: (data) =>
                    @setState data: data
            $.ajax
                url: "http://localhost:8000/heta/external_voucher/?project=#{projectId}"
                dataType: 'json'
                success: (data) =>
                    console.log data.results
                    @setState vouchers: data.results

        render: ->
            project = @state.data
            vouchers = @state.vouchers
            console.log vouchers
            <div>
                <h2>{project.name}</h2>
                {if vouchers != null
                    <RB.ListGroup>
                        {vouchers.map (voucher) ->
                            <RB.ListGroupItem key={voucher.id} header={voucher.ledger_account.name}>
                                <div className='pull-right'>{voucher.realization_total}</div>
                                <div className='pull-left'>{voucher.vendor.toimittaja_nimi_1}</div>
                            </RB.ListGroupItem>
                        }
                    </RB.ListGroup>
                else
                    <h3>Ei tositteita</h3>
                }
            </div>

    ProjectList = React.createClass
        getInitialState: -> data: []
        componentDidMount: ->
            ret = $.ajax
                url: 'http://localhost:8000/heta/project/'
                dataType: 'json'
                success: (data) =>
                    @setState data: data.results

        render: ->
            results = @state.data
            console.log results
            <div>
                <h2>{results.length} projektia</h2>
                <RB.ListGroup>
                    {results.map (project) ->
                        <RB.ListGroupItem href={'#project/' + project.id} header=project.id_str>{project.name}</RB.ListGroupItem>    
                    }
                </RB.ListGroup>
            </div>

    App = React.createClass
        render: ->
            <div>
                <RB.Navbar brand='Projektit'>
                    <RB.Nav>
                    </RB.Nav>
                </RB.Navbar>
                <div className="container">
                    <Router.RouteHandler />
                </div>
            </div>

    routes =
        <Router.Route name="app" path="/" handler={App}>
            <Router.Route name="project/:projectId" handler={Project} />
            <Router.DefaultRoute handler={ProjectList} />
        </Router.Route>

    Router.run routes, (Handler) ->
        React.render <Handler/>, document.body
