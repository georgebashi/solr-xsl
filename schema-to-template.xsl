<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">

    <xsl:output indent="yes" />
    <xsl:template match="/">
        <xsl:element name="xsl:stylesheet">
            <xsl:namespace name="xsl" select="'http://www.w3.org/1999/XSL/Transform'" />
            <xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'" />
            <xsl:attribute name="version" select="'2.0'" />

            <xsl:element name="xsl:template">
                <xsl:attribute name="name" select="'write-solr-doc'" />
                <xsl:attribute name="as" select="'element(doc)'" />

                <xsl:variable name="generated-code">
                    <xsl:apply-templates select="schema/fields/field" />
                </xsl:variable>

                <xsl:copy-of select="$generated-code/xsl:param" />
                <doc>
                    <xsl:copy-of select="$generated-code/*[not(local-name() = 'param')]" />
                </doc>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="field">
        <xsl:variable name="type-map">
            <type from="solr.BinaryField" to="xs:string" />
            <type from="solr.BoolField" to="xs:boolean" />
            <type from="solr.ByteField" to="xs:byte" />
            <type from="solr.DateField" to="xs:dateTime" />
            <type from="solr.DoubleField" to="xs:double" />
            <type from="solr.FloatField" to="xs:float" />
            <type from="solr.IntField" to="xs:integer" />
            <type from="solr.LegacyDateField" to="xs:dateTime" />
            <type from="solr.LongField" to="xs:long" />
            <type from="solr.ShortField" to="xs:short" />
            <type from="solr.SortableDoubleField" to="xs:double" />
            <type from="solr.SortableFloatField" to="xs:float" />
            <type from="solr.SortableIntField" to="xs:integer" />
            <type from="solr.SortableLongField" to="xs:long" />
            <type from="solr.StrField" to="xs:string" />
            <type from="solr.TextField" to="xs:string" />
            <type from="solr.TrieDateField" to="xs:dateTime" />
            <type from="solr.TrieDoubleField" to="xs:double" />
            <type from="solr.TrieFloatField" to="xs:float" />
            <type from="solr.TrieIntField" to="xs:integer" />
            <type from="solr.TrieLongField" to="xs:long" />
            <type from="solr.UUIDField" to="xs:string" />
        </xsl:variable>

        <xsl:variable name="type">
            <xsl:variable name="class">
                <xsl:variable name="class-name" select="@type" />
                <xsl:value-of select="/schema/types/fieldType[@name = $class-name]/@class" />
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$type-map/type[@from=$class]">
                    <xsl:value-of select="$type-map/type[@from=$class]/@to" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:text>Unknown field type:</xsl:text>
                        <xsl:value-of select="$class" />
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="seq-type">
            <xsl:choose>
                <xsl:when test="@required = 'true' and @multiValued = 'true'">
                    <xsl:value-of select="'+'" />
                </xsl:when>
                <xsl:when test="@multiValued = 'true'">
                    <xsl:value-of select="'*'" />
                </xsl:when>
                <xsl:when test="@required = 'true'">
                    <xsl:value-of select="''" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'?'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="name">
            <xsl:value-of select="@name" />
        </xsl:variable>
        <xsl:if test="count(/schema/copyField[@dest = $name]) = 0">
            <xsl:element name="xsl:param">
                <xsl:attribute name="name" select="$name" />
                <xsl:if test="@required = 'true'">
                    <xsl:attribute name="required" select="'yes'" />
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@default = 'NOW'">
                        <xsl:attribute name="select" select="'current-dateTime()'" />
                    </xsl:when>
                    <xsl:when test="@default">
                        <xsl:attribute name="select" select="concat('''', @default, '''')" />
                    </xsl:when>
                </xsl:choose>
                <xsl:attribute name="as" select="concat($type, $seq-type)" />
            </xsl:element>

            <xsl:choose>
                <xsl:when test="$seq-type = '*' or $seq-type = '+'">
                    <xsl:element name="xsl:for-each">
                        <xsl:attribute name="select" select="concat('$', $name)" />
                        <field name="{$name}">
                            <xsl:element name="xsl:copy-of">
                                <xsl:attribute name="select" select="'.'" />
                            </xsl:element>
                        </field>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$seq-type = '?'">
                    <xsl:element name="xsl:if">
                        <xsl:attribute name="test" select="concat('$', $name)" />
                        <field name="{$name}">
                            <xsl:element name="xsl:copy-of">
                                <xsl:attribute name="select" select="concat('$', $name)" />
                            </xsl:element>
                        </field>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <field name="{$name}">
                        <xsl:element name="xsl:copy-of">
                            <xsl:attribute name="select" select="concat('$', $name)" />
                        </xsl:element>
                    </field>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

    </xsl:template>
</xsl:stylesheet>
