console.log appSettings
conf = 
    baseUrl: appSettings.static_url

    paths:
        app: 'scripts'
        'react-bootstrap/lib': 'components/react-bootstrap/lib'

require.config conf

_deps = [
    'jquery', 'react-router', 'react', 'react-bootstrap', 'react-router-bootstrap',
    'react-loader'
]

format_date = (date) ->
    arr = date.split('-')
    arr.reverse()
    return arr.join '.'


require _deps, ($, Router, React, RB, RBR, Loader) ->
    VoucherModal = React.createClass
        render: ->
            propNames = (propName for propName of @props when typeof @props[propName] not in ['object', 'function'])
            propNames.sort()
            <RB.Modal onRequestHide={@props.onRequestHide}>
                <div className='modal-body'>
                    <RB.Table striped>
                        <tbody>
                            {propNames.map (propName) =>
                                <tr><td>{propName}</td><td>{@props[propName]}</td></tr>
                            }
                        </tbody>
                    </RB.Table>
                </div>
            </RB.Modal>

    Project = React.createClass
        contextTypes:
            router: React.PropTypes.func

        getInitialState: -> 
            return {
                project: {}, vouchers: null, 
                loaded: false, vouchersLoaded: false
            }
        componentDidMount: ->
            projectId = @context.router.getCurrentParams().projectId
            $.ajax
                url: "#{appSettings.api_base}/project/#{projectId}/"
                dataType: 'json'
                success: (data) =>
                    @setState project: data, loaded: true
            $.ajax
                url: "#{appSettings.api_base}/external_voucher/"
                data:
                    project: projectId
                    ordering: '-voucher_date'
                dataType: 'json'
                success: (data) =>
                    @setState vouchers: data.results, vouchersLoaded: true

        render: ->
            project = @state.project
            vouchers = @state.vouchers
            if @state.loaded
                document.title = project.name
            <div>
                <Loader loaded={@state.loaded}>
                    <h2>{project.name}</h2>
                </Loader>
                <Loader loaded={@state.vouchersLoaded}>
                    {if vouchers and vouchers.length
                        <RB.ListGroup>
                            {vouchers.map (voucher) ->
                              <RB.ModalTrigger modal={<VoucherModal {...voucher} />}>
                                <RB.ListGroupItem key={voucher.id}
                                    header={"#{format_date(voucher.voucher_date)} #{voucher.ledger_account.name}"}>
                                        <div className='pull-left'>
                                            {voucher.vendor.toimittaja_nimi_1}
                                        </div>
                                        <div className='pull-right'>
                                            {voucher.realization_total}
                                        </div>
                                        <div className='clearfix' />
                                </RB.ListGroupItem>
                              </RB.ModalTrigger>
                            }
                        </RB.ListGroup>
                    else
                        <h3>Ei tositteita</h3>
                    }
                </Loader>
            </div>

    ProjectList = React.createClass
        getInitialState: -> projects: [], loaded: false
        componentDidMount: ->
            ret = $.ajax
                url: "#{appSettings.api_base}/project/"
                dataType: 'json'
                data:
                    ordering: 'name'
                    count: 'external_vouchers'
                success: (data) =>
                    @setState projects: data.results, loaded: true

        render: ->
            projects = @state.projects
            <div>
                <Loader loaded={@state.loaded}>
                    <h2>{projects.length} projektia</h2>
                    <RB.ListGroup>
                        {projects.map (project) ->
                            <RB.ListGroupItem href={'#project/' + project.id} header=project.id_str>
                                <div className='pull-left'>{project.name}</div>
                                {if project.external_vouchers_count 
                                    <div className='pull-right'>{project.external_vouchers_count}</div>
                                }
                                <div className='clearfix'></div>
                            </RB.ListGroupItem>    
                        }
                    </RB.ListGroup>
                </Loader>
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
