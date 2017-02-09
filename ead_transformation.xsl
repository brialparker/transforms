<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:ead="urn:isbn:1-931666-22-9" version="2.0" exclude-result-prefixes="xsl xlink ead xs">

    <!--standard identity template, which does all of the copying-->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- gets rid of many elements with empty or null values -->
    <xsl:template match="scopecontent[contains(text(), 'null')]"/>
    <xsl:template
        match="unittitle[text() = 'null'] | unitdate[text() = 'null'] | item[text() = 'null'] | extent[text() = 'null']"/>
    <xsl:template match="processinfo[contains(text(), 'null')]"/>
    <xsl:template match="userestrict[descendant::text() = 'null']"/>
    <xsl:template match="acqinfo[descendant::text() = 'null']"/>

    <xsl:template match="list/item/*[not(node())]"/>
    <xsl:template
        match="list/*[not(node())] | abstract/*[not(node())] | unitdate/*[not(node())] | date/*[not(node())] | physdesc/*[not(node())]"/>
    <xsl:template match="physdesc/extent/*[not(node())]"/>
    <xsl:template match="scopecontent/p/*[not(node())]"/>
    <xsl:template match="physloc"/>

    <!--creates an archivesspace component_id for series and subseries using the enumeration in the id attribute) -->
     <xsl:template match="c01[@level='series']/did/unittitle">
     <xsl:copy>
        <xsl:apply-templates select="@*|node()"/> 
     </xsl:copy> 
         <unitid>
            <xsl:value-of select="translate(ancestor::c01/@id, 'series', '')"/>
         </unitid>   
  </xsl:template> 

       <xsl:template match="c02[@level='subseries']/did/unittitle">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/> 
        </xsl:copy> 
        <unitid>
            <xsl:value-of select="translate(ancestor::c02/@id, 'subseries', '')"/>
        </unitid>   
    </xsl:template>  
    
    <!--adds label attribute to the box container that generates a dummy barcode, along with instance type. -->
    <!-- Our container ids already match across the same box, so combining with dsc id creates a unique id for each box -->
    <xsl:template match="container[@type='box'][not(.='')]">
        <xsl:choose>
            <xsl:when test="not(@label)">
        <xsl:copy>
            <xsl:attribute name="label">
                <xsl:copy-of select="concat('Mixed materials ', '(', ancestor::dsc/@id, self::container/@id, ')')"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
            </xsl:when>
        </xsl:choose> 
     </xsl:template> 

    <!-- This is only needed in special cases where multiple instances are described, but the second instance is not in a container element, but instead noted in physDesc. -->
    <!-- This pulls out the reel/frame data, parses it, and creates new instances for the object, including instance type, reel/frame number, component_unique_id, and dummy barcode -->
    <xsl:template match="c02">
        <xsl:choose>
            <xsl:when test="contains(did/physdesc, 'Reel')">
                <xsl:for-each select="did">
                    <xsl:variable name="id"
                        select="replace(physdesc, 'Reel (\d{1,}), Frame (\d{1,}).*', '$1.$2')"/>
                    <xsl:variable name="reel"
                        select="replace(physdesc, 'Reel (\d{1,}), Frame (\d{1,}).*', '$1')"/>
                    <xsl:variable name="frame"
                        select="replace(physdesc, 'Reel (\d{1,}), Frame (\d{1,}).*', '$2')"/>

                    <c02 level="file">
                        <xsl:copy>
                            <unitid>
                                <xsl:value-of select="$id"/>
                            </unitid>
                            <xsl:apply-templates select="@* | node()"/>
                            <container type="reel">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                <xsl:attribute name="label">
                                    <xsl:value-of
                                        select="concat('Mixed materials ', '(', 'TESTING_reel', $reel, ')')"
                                    />
                                </xsl:attribute>
                                <xsl:value-of select="$reel"/>
                            </container>

                            <container type="frame">
                                <xsl:attribute name="parent">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                <xsl:value-of select="$frame"/>
                            </container>
                        </xsl:copy>
                    </c02>

                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="c03[@level = 'file']">
        <xsl:choose>
            <xsl:when test="contains(did/physdesc, 'Reel')">
                <xsl:for-each select="did">
                    <xsl:variable name="id"
                        select="replace(physdesc, 'Reel (\d{1,}), Frame (\d{1,}).*', '$1.$2')"/>
                    <xsl:variable name="reel"
                        select="replace(physdesc, 'Reel (\d{1,}), Frame (\d{1,}).*', '$1')"/>
                    <xsl:variable name="frame"
                        select="replace(physdesc, 'Reel (\d{1,}), Frame (\d{1,}).*', '$2')"/>
                    <c03 level="file">
                        <xsl:copy>
                            <unitid>
                                <xsl:value-of select="$id"/>
                            </unitid>
                            <xsl:apply-templates select="@* | node()"/>
                            <container type="reel">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                <xsl:attribute name="label">
                                    <xsl:value-of
                                        select="concat('Mixed materials ', '(', 'TESTING_reel', $reel, ')')"
                                    />
                                </xsl:attribute>
                                <xsl:value-of select="$reel"/>
                            </container>
                            <container type="frame">
                                <xsl:attribute name="parent">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>
                                <xsl:value-of select="$frame"/>
                            </container>
                        </xsl:copy>
                    </c03>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- removes 'box' from in front of parent id number -->
    <xsl:template match="container/@parent">
        <xsl:attribute name="parent">
            <xsl:value-of select="translate(., 'box', '')"/>
        </xsl:attribute>
    </xsl:template>

    <!-- pulls in title subelement with unittitle element for required dao title attribute -->
   <xsl:template match="did/dao">
        <xsl:copy>
            <xsl:attribute name="title">
                 <xsl:copy-of select="preceding-sibling::unittitle"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template> 

</xsl:stylesheet>
