<%@ page import="au.org.ala.collectory.CollectionLocation; grails.converters.*" %>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="layout" content="${grailsApplication.config.skin.layout}" />
        <title><g:message code="public.map3.title" /> | ${grailsApplication.config.projectName}</title>
        <r:require modules="google-maps-api,bigbuttons,bbq,openlayers,map"/>
    </head>
    <body id="page-collections-map" class="nav-datasets">
    <div id="content">
      <div id="header">
        <!--Breadcrumbs-->
        <div id="breadcrumb">
          <ol class="breadcrumb">
              <li><cl:breadcrumbTrail /></li>
          </ol>
        </div>
        <div class="section full-width">
          <g:if test="${flash.message}">
            <div class="message">${flash.message}</div>
          </g:if>
          <div class="hrgroup">
            <h1>${grailsApplication.config.regionName}<g:message code="public.map3.header.title" /></h1>
            <p><g:message code="public.map3.header.des01" /> ${grailsApplication.config.projectNameShort} <g:message code="public.map3.header.des02" args="[grailsApplication.config.regionName]"/>.</p>
          </div><!--close hrgroup-->
        </div><!--close section-->
      </div><!--close header-->

      <div class="row-fluid"><!-- wrap map and list-->
        <div class="span4">
          <div class="section">
            <p><g:message code="public.map3.des01" />.</p>
          </div>
          <div class="section filter-buttons">
            <div class="all selected" id="all" onclick="toggleButton(this);return false;">
              <h2><a href=""><g:message code="public.map3.link.allcollections" /><span id="allButtonTotal"> <collections></collections></span></a></h2>
            </div>
            <div class="fauna" id="fauna" onclick="toggleButton(this);return false;">
              <h2><a href=""><g:message code="public.map3.link.fauna" /><span><g:message code="public.map3.link.mammals" />.</span></a></h2>
            </div>
            <div class="insects" id="entomology" onclick="toggleButton(this);return false;">
              <h2><a href=""><g:message code="public.map3.link.insect" /><span><g:message code="public.map3.link.insects" />.</span></a></h2>
            </div>
            <div class="microbes" id="microbes" onclick="toggleButton(this);return false;">
              <h2><a href=""><g:message code="public.map3.link.mos" /><span><g:message code="public.map3.link.protists" />.</span></a></h2>
            </div>
            <div class="plants" id="plants" onclick="toggleButton(this);return false;">
              <h2><a href=""><g:message code="public.map3.link.plants" /><span><g:message code="public.map3.link.vascular" />.</span></a></h2>
            </div>
          </div><!--close section-->
          <div id="collectionTypesFooter">
            <h4 class="collectionsCount"><span id='numFeatures'></span></h4>
            <h4 class="collectionsCount"><span id='numVisible'></span>
                <br/><span id="numUnMappable"></span>
            </h4>
          </div>

        </div><!--close column-one-->

        <div class="span8" id="map-list-col">
            <div class="tabbable">
                <ul class="nav nav-tabs" id="home-tabs">
                    <li><a href="#map" class="active" data-toggle="tab"><g:message code="public.map3.maplistcol.map" /></a></li>
                    <li ><a href="#list" data-toggle="tab"><g:message code="public.map3.maplistcol.list" /></a></li>


                </ul>
            </div>
            <div class="tab-content">
              <div class="tab-pane  active" id="map">
              <div  class="map-column">
                <div class="section">
                  <p style="width:100%;padding-bottom:8px;"><g:message code="public.map3.maplistcol.des01" />.</p>
                  <div id="map-container">
                    <div id="map_canvas"></div>
                  </div>
                  <p style="padding-left:150px;"><img style="vertical-align: middle;" src="${resource(dir:'images/map', file:'orange-dot-multiple.png')}" width="20" height="20"/><g:message code="public.map3.maplistcol.des02" />.<br/></p>
                </div><!--close section-->
              </div><!--close column-two-->
            </div><!--close map-->

            <div id="list" class="tab-pane">
              <div  class="list-column">
                <div class="nameList section" id="names">
                  <p><span id="numFilteredCollections"><g:message code="public.map3.maplistcol.des03" /></span>. <g:message code="public.map3.maplistcol.des04" /> <img style="vertical-align:middle" src="${resource(dir:'images/map', file:'nomap.gif')}"/>.</p>

                  <ul id="filtered-list" style="padding-left:15px;">

                    <g:each var="c" in="${collections}" status="i">
                      <li>
                        <g:link controller="public" action="show" id="${c.uid}">${fieldValue(bean: c, field: "name")}</g:link>
                        <g:if test="${!c.canBeMapped()}">
                          <img style="vertical-align:middle" src="${resource(dir:'images/map', file:'nomap.gif')}"/>
                        </g:if>

                      </li>
                    </g:each>

                  </ul>
                    <p><g:message code="public.map3.maplistcol.des05" />:</p>

                    <ul id="list-inst" style="padding-left:15px;">
                        <g:each var="i" in="${ (2..<53) }">
                            <g:if test="${i != 18 && i != 19 && i != 47}">
                                <%
                                    def urlInst = 'http://www.gbif.ad/collectory/ws/institution/in' + i
                                    def data = JSON.parse( new URL( urlInst ).text )
                                %>
                                <g:set var="institution" value="${data}"/>

                                <li style="padding-left:15px;"><a href="http://www.gbif.ad/generic-hub/occurrences/search?q=*%3A*&fq=institution_code:%22${institution.acronym}%22#tab_recordsView">(${institution.acronym})</a> - <g:link action="show" controller="public" id="${institution.uid}">${institution.name}</g:link></li>
                            </g:if>
                        </g:each>
                    </ul>
                </div><!--close nameList-->
              </div><!--close column-one-->
            </div><!--close list-->
        </div><!-- /.tab-content -->
      </div><!--close map/list div-->
    </div><!--close content-->
    </div>
  </body>
  <r:script>
      var altMap = true;
      var COLLECTIONS_MAP_OPTIONS = {
          contextPath: "${grailsApplication.config.contextPath}",
          serverUrl:   "${grailsApplication.config.grails.serverURL}",
          centreLat:   ${grailsApplication.config.collectionsMap.centreMapLat?:'-28.2'},
          centreLon:   ${grailsApplication.config.collectionsMap.centreMapLon?:'134'},
          defaultZoom: ${grailsApplication.config.collectionsMap.defaultZoom?:'4'}
      }
      initMap(COLLECTIONS_MAP_OPTIONS);
  </r:script>
</html>