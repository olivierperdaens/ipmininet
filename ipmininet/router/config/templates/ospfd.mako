hostname ${node.name}
password ${node.password}

% if node.ospfd.logfile:
log file ${node.ospfd.logfile}
% endif

% for section in node.ospfd.debug:
debug ospf ${section}
% endfor

% for intf in node.ospfd.interfaces:
interface ${intf.name}
# ${intf.description}
  # Highest priority routers will be DR
  ip ospf priority ${intf.priority}
  ip ospf cost ${intf.cost}
  % if not intf.passive and intf.active:
  ip ospf dead-interval ${intf.dead_int}
  ip ospf hello-interval ${intf.hello_int}
  % endif
  
  ip ospf message-digest-key 1 md5 newpassword
  <%block name="interface"/>
!
% endfor

router ospf
  ospf router-id ${node.ospfd.routerid}
  % for r in node.ospfd.redistribute:
  redistribute ${r.subtype} metric-type ${r.metric_type} metric ${r.metric}
  % endfor
  % for net in node.ospfd.networks:
    network ${net.domain.with_prefixlen} area ${net.area}
  % endfor
  % for itf in node.ospfd.interfaces:
      % if itf.passive or not itf.active:
  passive-interface ${itf.name}
    % endif
  % endfor

  area 0 authentication message-digest


  <%block name="router"/>
!
