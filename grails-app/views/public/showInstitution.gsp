<%@ page contentType="text/html;charset=UTF-8" import="au.org.ala.collectory.DataResource; au.org.ala.collectory.Institution; grails.converters.*" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title><cl:pageTitle>${fieldValue(bean: instance, field: "name")}</cl:pageTitle></title>
    <script type="text/javascript" language="javascript" src="http://www.google.com/jsapi"></script>
    <r:require modules="jquery, fancybox, jquery_jsonp, charts"/>
    <r:script type="text/javascript">
      biocacheServicesUrl = "${grailsApplication.config.biocacheServicesUrl}";
      biocacheWebappUrl = "${grailsApplication.config.biocacheUiURL}";
      loadLoggerStats = ${!grailsApplication.config.disableLoggerLinks.toBoolean()};
      $(document).ready(function () {
        $("a#lsid").fancybox({
            'hideOnContentClick': false,
            'titleShow': false,
            'autoDimensions': false,
            'width': 600,
            'height': 180
        });
        $("a.current").fancybox({
            'hideOnContentClick': false,
            'titleShow': false,
            'titlePosition': 'inside',
            'autoDimensions': true,
            'width': 300
        });
      });
    </r:script>
</head>

<body>
<div id="content">
    <div id="header" class="collectory">
        <!--Breadcrumbs-->
        <div id="breadcrumb">
            <ol class="breadcrumb">
                <li><cl:breadcrumbTrail/> <span class=" icon icon-arrow-right"></span></li>
                <li><cl:pageOptionsLink>${fieldValue(bean:instance,field:'name')}</cl:pageOptionsLink></li>
            </ol>
        </div>
        <cl:pageOptionsPopup instance="${instance}"/>
        <div class="row-fluid">
            <div class="span8">
                <cl:h1 value="${instance.name}"/>
                <g:set var="parents" value="${instance.listParents()}"/>
                <g:each var="p" in="${parents}">
                    <h2><g:link action="show" id="${p.uid}">${p.name}</g:link></h2>
                </g:each>
                <cl:valueOrOtherwise value="${instance.acronym}"><span
                        class="acronym"><g:message code="public.show.header.acronym"/>: ${fieldValue(bean: instance, field: "acronym")}</span></cl:valueOrOtherwise>
                <g:if test="${instance.guid?.startsWith('urn:lsid:')}">
                    <span class="lsid"><a href="#lsidText" id="lsid" class="local"
                                          title="Life Science Identifier (pop-up)"><g:message code="public.lsid" /></a></span>

                    <div style="display:none; text-align: left;">
                        <div id="lsidText" style="text-align: left;">
                            <b><a class="external_icon" href="http://lsids.sourceforge.net/"
                                  target="_blank"><g:message code="public.lsidtext.link" />:</a></b>
                            <p><cl:guid target="_blank" guid='${fieldValue(bean: instance, field: "guid")}'/></p>
                            <p><g:message code="public.lsidtext.des" />.</p>
                        </div>
                    </div>
                </g:if>
            </div>

            <div class="span4">
                <g:if test="${fieldValue(bean: instance, field: 'logoRef') && fieldValue(bean: instance, field: 'logoRef.file')}">
                    <img class="institutionImage"
                         src='${resource(absolute: "true", dir: "data/institution/", file: fieldValue(bean: instance, field: 'logoRef.file'))}'/>
                </g:if>
            </div>
        </div>
    </div><!--close header-->
    <div class="row-fluid">
            <div class="span8">
                <g:if test="${instance.pubDescription}">
                    <h2><g:message code="public.des" /></h2>
                    <cl:formattedText>${fieldValue(bean: instance, field: "pubDescription")}</cl:formattedText>
                    <cl:formattedText>${fieldValue(bean: instance, field: "techDescription")}</cl:formattedText>
                </g:if>
                <g:if test="${instance.focus}">
                    <h2><g:message code="public.si.content.label02" /></h2>
                    <cl:formattedText>${fieldValue(bean: instance, field: "focus")}</cl:formattedText>
                </g:if>
                <h2><g:message code="public.si.content.label03" /></h2>
                <ol>
                    <g:each var="c" in="${instance.listCollections().sort { it.name }}">
                        <li><g:link controller="public" action="show"
                                    id="${c.uid}">${c?.name}</g:link> ${c?.makeAbstract(400)}</li>
                    </g:each>

                    <g:if test="${instance.uid != 'in0' && instance.uid != 'in18' && instance.uid != 'in19' && instance.uid != 'in47'}">
                        <%
                            def url = 'http://www.gbif.ad/biocache-service/occurrences/search?q=*%3A*&fq=institution_uid%3A' + instance.uid
                            def data = JSON.parse( new URL( url ).text )
                        %>
                        <g:set var="occurrences" value="${data}"/>
                        <g:set var="numOcc" value="${occurrences.totalRecords}"/>

                        <%
                            def dataResourcesUids = occurrences.occurrences.dataResourceUid
                            def uniqueListDr = dataResourcesUids.unique { a, b -> a <=> b }
                            def sumOcc = 0
                            def i = 0
                        %>

                        <g:each in="${occurrences.facetResults.fieldName}" var="fr">
                        %{--${occurrences.facetResults.fieldName[i]}--}%
                        <g:if test="${occurrences.facetResults.fieldName[i] != 'collection_uid' }">
                            <g:set var="i" value="${i = i+1}"/>
                        </g:if>
                        </g:each>

                        <g:each in="${occurrences.facetResults.fieldResult[i]}" var="co">
                            <%
                                def url2 = 'http://wwww.gbif.ad/collectory/ws/collection/' + co.label
                                def data2 = JSON.parse( new URL( url2 ).text )

                                sumOcc = sumOcc + co.count
                            %>

                            <g:set var="collection" value="${data2}"/>
                            <li><a href="http://gbif-ad-dev.org/generic-hub/occurrences/search?q=*%3A*&fq=institution_code%3A%22UB%22&fq=collection_uid%3A%22${co.label}%22#tab_recordsView">${collection.name}</a> - <g:formatNumber number="${co.count}" format="#.###" /> <g:message code="public.si.content.label05" /></li>
                        </g:each>
                        <br>
                        <g:if test="${instance.uid != 'in0'}">
                            <h2 style="margin-left: -25px"><g:message code="public.numbrs.des03" /></h2> <br> <span style="margin-left: -25px">${sumOcc} <g:message code="public.numbrs.des02" />.<br>
                            <a style="margin-left: -25px" href="http://gbif-ad-dev.org/generic-hub/occurrences/search?q=*%3A*&fq=institution_code%3A${instance.acronym}"><g:message code="public.numbrs.link" /> ${instance.name}.</a></span>
                        </g:if>
                    </g:if>
                </ol>

                <%--<div id='usage-stats'>
                    <h2><g:message code="public.usagestats.label" /></h2>

                    <div id='usage'>
                        <p><g:message code="public.usage.des" />...</p>
                    </div>
                </div>
                --%>

                <g:if test="${instance.uid == 'in0'}">
                    <h2><g:message code="public.si.content.label04" /></h2>
                    <div>
                        <p style="padding-bottom:8px;">
                            <span id="numBiocacheRecords"><g:message code="public.numbrs.des01" /></span> <g:message code="public.numbrs.des02" />.
                        </p>

                        <cl:recordsLink
                                entity="${instance}"><g:message code="public.numbrs.link" /> ${instance.name}.</cl:recordsLink>
                    </div>

                    <div id="recordsBreakdown" class="section vertical-charts">
                        <div id="charts"></div>
                    </div>
                </g:if>


                <cl:lastUpdated date="${instance.lastUpdated}"/>

            </div><!--close section-->
            <div class="span4">
                <g:if test="${fieldValue(bean: instance, field: 'imageRef') && fieldValue(bean: instance, field: 'imageRef.file')}">
                    <div class="section">
                        <img alt="${fieldValue(bean: instance, field: "imageRef.file")}"
                             src="${resource(absolute: "true", dir: "data/institution/", file: instance.imageRef.file)}"/>
                        <cl:formattedText
                                pClass="caption">${fieldValue(bean: instance, field: "imageRef.caption")}</cl:formattedText>
                        <cl:valueOrOtherwise value="${instance.imageRef?.attribution}"><p
                                class="caption">${fieldValue(bean: instance, field: "imageRef.attribution")}</p></cl:valueOrOtherwise>
                        <cl:valueOrOtherwise value="${instance.imageRef?.copyright}"><p
                                class="caption">${fieldValue(bean: instance, field: "imageRef.copyright")}</p></cl:valueOrOtherwise>
                    </div>
                </g:if>

                <div id="dataAccessWrapper" style="display:none;">
                    <g:render template="dataAccess" model="[instance:instance]"/>
                </div>

                <div class="section">
                    <h3><g:message code="public.location" /></h3>
                    <g:if test="${instance.address != null && !instance.address.isEmpty()}">
                        <p>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.street}">${instance.address?.street}<br/></cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.city}">${instance.address?.city}<br/></cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.state}">${instance.address?.state}</cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.postcode}">${instance.address?.postcode}<br/></cl:valueOrOtherwise>
                            <cl:valueOrOtherwise
                                    value="${instance.address?.country}">${instance.address?.country}<br/></cl:valueOrOtherwise>
                        </p>
                    </g:if>
                    <g:if test="${instance.email}"><cl:emailLink>${fieldValue(bean: instance, field: "email")}</cl:emailLink><br/></g:if>
                    <cl:ifNotBlank value='${fieldValue(bean: instance, field: "phone")}'/>
                </div>

            <!-- contacts -->
                <g:render template="contacts" bean="${instance.getPublicContactsPrimaryFirst()}"/>

            <!-- web site -->
                <g:if test="${instance.websiteUrl}">
                    <div class="section">
                        <h3><g:message code="public.website" /></h3>

                        <div class="webSite">
                            <a class='external' target="_blank"
                               href="${instance.websiteUrl}"><g:message code="public.si.website.link01" /> <cl:institutionType
                                    inst="${instance}"/><g:message code="public.si.website.link02" /></a>
                        </div>
                    </div>
                </g:if>

            <!-- network membership -->
                <g:if test="${instance.networkMembership}">
                    <div class="section">
                        <h3><g:message code="public.network.membership.label" /></h3>
                        <g:if test="${instance.isMemberOf('CHAEC')}">
                            <p><g:message code="public.network.membership.des01" /></p>
                            <img src="${resource(absolute: "true", dir: "data/network/", file: "chaec-logo.png")}"/>
                        </g:if>
                        <g:if test="${instance.isMemberOf('CHAH')}">
                            <p><g:message code="public.network.membership.des02" /></p>
                            <a target="_blank" href="http://www.chah.gov.au"><img style="padding-left:25px;"
                                                                                  src="${resource(absolute: "true", dir: "data/network/", file: "CHAH_logo_col_70px_white.gif")}"/>
                            </a>
                        </g:if>
                        <g:if test="${instance.isMemberOf('CHAFC')}">
                            <p><g:message code="public.network.membership.des03" /></p>
                            <img src="${resource(absolute: "true", dir: "data/network/", file: "CHAFC_sm.jpg")}"/>
                        </g:if>
                        <g:if test="${instance.isMemberOf('CHACM')}">
                            <p><g:message code="public.network.membership.des04" /></p>
                            <img src="${resource(absolute: "true", dir: "data/network/", file: "chacm.png")}"/>
                        </g:if>
                    </div>
                </g:if>
            </div>
        </div><!--close content-->
</div>
<r:script type="text/javascript">
      // configure the charts
      var facetChartOptions = {
          /* base url of the collectory */
          collectionsUrl: "${grailsApplication.config.grails.serverURL}",
          /* base url of the biocache ws*/
          biocacheServicesUrl: biocacheServicesUrl,
          /* base url of the biocache webapp*/
          biocacheWebappUrl: biocacheWebappUrl,
          /* a uid or list of uids to chart - either this or query must be present
            (unless the facet data is passed in directly AND clickThru is set to false) */
          instanceUid: "${instance.descendantUids().join(',')}",
          /* the list of charts to be drawn (these are specified in the one call because a single request can get the data for all of them) */
          charts: ['country','state','species_group','assertions','type_status',
              'biogeographic_region','state_conservation','occurrence_year']
      }
      var taxonomyChartOptions = {
          /* base url of the collectory */
          collectionsUrl: "${grailsApplication.config.grails.serverURL}",
          /* base url of the biocache ws*/
          biocacheServicesUrl: biocacheServicesUrl,
          /* base url of the biocache webapp*/
          biocacheWebappUrl: biocacheWebappUrl,
          /* a uid or list of uids to chart - either this or query must be present */
          instanceUid: "${instance.descendantUids().join(',')}",
          /* threshold value to use for automagic rank selection - defaults to 55 */
          threshold: 55,
          rank: "${instance.startingRankHint()}"
      }
    /************************************************************\
     * Add points to number strings
     \************************************************************/

    function numberWithPoints(x) {
        return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }
    function setNumbers(totalBiocacheRecords) {
      var recordsClause = "";
      switch (totalBiocacheRecords) {
        //case 0: recordsClause = "No records"; break;
        //case 1: recordsClause = "1 record"; break;
        //default: recordsClause = addCommas(totalBiocacheRecords) + " records";
        case 0: recordsClause = jQuery.i18n.prop('collectory.js.norecord'); break;
        case 1: recordsClause = "1 " + jQuery.i18n.prop('collectory.js.record'); break;
        default: recordsClause = numberWithPoints(totalBiocacheRecords) + " " + jQuery.i18n.prop('collectory.js.records');
      }
      $('#numBiocacheRecords').html(recordsClause);
    }
    /************************************************************\
    * Actions when page is loaded
    \************************************************************/
    function onLoadCallback() {

      // stats
      if(loadLoggerStats){
        loadDownloadStats("${grailsApplication.config.loggerURL}", "${instance.uid}","${instance.name}", "1002");
      }

      // records
      $.ajax({
        url: urlConcat(biocacheServicesUrl, "/occurrences/search.json?pageSize=0&q=") + buildQueryString("${instance.descendantUids().join(',')}"),
        dataType: 'jsonp',
        timeout: 20000,
        complete: function(jqXHR, textStatus) {
            if (textStatus == 'timeout') {
                noData();
                alert('Sorry - the request was taking too long so it has been cancelled.');
            }
            if (textStatus == 'error') {
                noData();
                alert('Sorry - the records breakdowns are not available due to an error.');
            }
        },
        success: function(data) {
            // check for errors
            if (data.length == 0 || data.totalRecords == undefined || data.totalRecords == 0) {
                noData();
            } else {
                setNumbers(data.totalRecords);
                // draw the charts
                drawFacetCharts(data, facetChartOptions);
                if(data.totalRecords > 0){
                    $('#dataAccessWrapper').css({display:'block'});
                    $('#totalRecordCountLink').html(data.totalRecords.toLocaleString() + " ${g.message(code: 'public.show.rt.des03')}");
                }
            }
        }
      });

      // taxon chart
      loadTaxonomyChart(taxonomyChartOptions);
    }
    /************************************************************\
    *
    \************************************************************/

    google.load("visualization", "1", {packages:["corechart"]});
    google.setOnLoadCallback(onLoadCallback);

</r:script>
</body>
</html>