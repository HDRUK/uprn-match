package org.endeavourhealth.uprnAlgorithm.repository;

import com.mysql.cj.jdbc.MysqlDataSource;

import java.io.*;
import java.sql.*;
import java.util.*;

import static org.endeavourhealth.uprnAlgorithm.common.uprnCommon.*;

public class Repository {

    private MysqlDataSource dataSource;
    private Connection connection;

    public String adrec;

    public Repository(Properties properties) throws SQLException {
        init( properties );
    }

    private void init(Properties props) throws SQLException {

    try {

	    String url = props.getProperty("url");
        String username = props.getProperty("username");
        String pass = props.getProperty("password");

        dataSource = new MysqlDataSource();

        dataSource.setURL(url);
        dataSource.setUser(username);
        dataSource.setPassword(pass);

        dataSource.setReadOnlyPropagatesToServer(true);

        connection = dataSource.getConnection();

        }
        catch(Exception e)
        {
            System.out.println(e);
        }
    }

    public String QueryDictionary(String node, String word) throws SQLException
    {
        String data = "";

        word = word.replaceAll("'","''");

        String q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = '"+node+"' and n2='" + word + "'";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            data = rs.getString("data");
            if (data.isEmpty()) data = rs.getString("n1");
        }

        preparedStatement.close();

        return data;
    }

    public Integer QueryIndexes(String data, String column) throws SQLException
    {
        Integer in = 0;

        data = data.replace("'", "''");

        // select post from uprn_v2.uprn_main WHERE post = 'ig110rf'
        String q = "SELECT "+column+" FROM uprn_v2.uprn_main WHERE "+column+" = '" +data+ "'";

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {in=1;}

        return in;
    }

    public Integer floor(String floor) throws SQLException
    {
        Integer n = 0;

        floor = floor.replace("'", "''");

        String q ="SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLOOR' and n2 = '"+floor+"'";
        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) { n = 1; }
        preparedStmt.close();

        return n;
    }


    public Integer isroad(String text) throws SQLException {
        Integer n = 0;

        text = text.replace("'", "''");

        String q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'ROAD' and n2='"+text+"'";
        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) { n = 1; }

        preparedStmt.close();

        return n;
    }

    public Integer TOWN(String data) throws SQLException {
        Integer n = 0;

        data = data.replace("'", "''");

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'TOWN' and data='"+data+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer FLAT(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT' and n2='"+text+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer VERTICALS(String text) throws SQLException {
        Integer n = 0;

        text = text.replace("'","''");

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'VERTICALS' and n2='"+text+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer COURT(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'COURT' and n2='"+text+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer BUILDING(String text) throws SQLException {
        Integer n = 0;

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'BUILDING' and n2='"+text+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        if (rs.next()) {
            n = 1;
        }

        preparedStmt.close();

        return n;
    }

    public Integer hasflat(String text) throws SQLException {
        Integer hasflat = 0;
        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` WHERE n1='FLAT'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();

        while (rs.next()) {
            String word = rs.getString("n2");
            if ((" "+text+" ").contains(" "+word+ " ")) {
                hasflat = 1;
            }
        }

        return hasflat;
    }

    public Integer isflat(String text) throws SQLException {
        Integer n = 0;

        if (Piece(text, " ",1 ,1).equals("tower") && RegEx(Piece(text, " ",2, 2),"^[0-9][a-z]+$").equals(10)) {
            return 0;
        }

        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        while (rs.next()) {
            String word = rs.getString("n2");
            if (Piece(text," ",1,1).equals(word)) {
                n = 1;
            }
        }

        if (RegEx(text, "^[a-z]+( )\\w+$").equals(1) && floor(text).equals(1)) {n=1;}

        return n;
    }

    public Integer QueryFlat(String text) throws SQLException {
        Integer n = 0;
        String q = "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT' and n2='"+text+"'";

        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();
        while (rs.next()) {
            String word = rs.getString("n2");
            if (Piece(text," ",1,1).equals(word)) {
                n = 1;
            }
        }
        // is floor
        // i text?1l.l1" ".e,$d(^UPRNS("FLOOR",text)) q 1
        // ^[a-z]+( )\w+$
        if (RegEx(text, "^[a-z]+( )\\w+$").equals(1) && floor(text).equals(1)) {n=1;}
        preparedStmt.close();

        return n;
    }

    public String flat(String text) throws SQLException {
        String q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT'";
        PreparedStatement preparedStmt = connection.prepareStatement(q);

        ResultSet rs = preparedStmt.executeQuery();

        while (rs.next()) {
            String word = rs.getString("n2");
            if (text.contains(word+" ")) {
                String a = Piece(text, word+" ",1, 1);
                String b = Piece(text, word+" ", 2, 20);
                text = a + b;
            }
        }

        preparedStmt.close();

        // for  q:($e(text)'="0")  s text=$e(text,2,50)
        for (;;){
            if (!text.substring(0, 0).equals("0")) {break;}
            text = text.substring(1,49);
        }

        // Flat at end
        String p[] = text.split(" ",-1);
        if (indexInBound(p, 1)) {
            // get last piece
            String flat = p[p.length-1];
            // flat exist in uprn-s?
            q= "SELECT * FROM uprn_v2.`uprn_dictionary` where n1 = 'FLAT' and n2='"+flat+"'";
            preparedStmt = connection.prepareStatement(q);
            rs = preparedStmt.executeQuery();
            // flat at end
            if (rs.next()) {
                //text = rs.getString("n2");
                text = Piece(text, " ", 1, CountPieces(text, " ")-1);
            }
        }

        preparedStmt.close();

        return text;
    }

    // X.BLD
    public Integer XBLD(String building, Integer like) throws SQLException
    {
        Integer in = 0;

        String e = "="; String p = ""; String limit = " limit 1";
        if (like.equals(1)) {
            e = "like"; p = "%";
            limit = "";
        }

        building = building.replace("'", "''");

        String q ="SELECT street from uprn_v2.uprn_main where build "+e+" '" + building +p + "'"+limit;

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();
        return in;
    }

    // X.STR
    public Integer XSTR(String street, Integer like) throws SQLException
    {
        Integer in = 0;

        //System.out.println("["+street+"]");
        if (street.isEmpty()) {
            //System.out.println("street is null!");
            return 0;
        }

        String e = "="; String p = ""; String limit = " limit 1";

        // test - please remove
        //limit = "";

        if (like.equals(1)) {
            e = "like"; p = "%";
            limit = "";
        }

        street = street.replace("'", "''");

        String q ="SELECT street from uprn_v2.uprn_main where street "+e+" '" + street +p+"' "+limit;
        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();

        if (rs.next()) {
            in = 1;
        }

        preparedStatement.close();

        return in;
    }

    // OutOfArea
    public Integer inpost(String area, String qpost) throws SQLException
    {
        Integer in = 0;
        String q = "SELECT * FROM uprn_v2.uprn_dictionary where n1 = 'AREAS' and `data` = '"+area+"'";
        if (!qpost.isEmpty()) {
            q = "SELECT * FROM uprn_v2.uprn_dictionary where n1 = 'AREAS' and `data` = '"+qpost+"'";
        }

        PreparedStatement preparedStatement = connection.prepareStatement(q);
        ResultSet rs = preparedStatement.executeQuery();
        if (rs.next()) {in = 1;}
        preparedStatement.close();

        return in;
    }

    public String GetUPRN() throws SQLException {
        // test that we can connect to the mysql database?
        String preparedSql = "SELECT * FROM uprn_v2.`uprn_dictionary` limit 10";
        PreparedStatement preparedStatement = connection.prepareStatement( preparedSql );

        ResultSet rs = preparedStatement.executeQuery();
        while (rs.next()) {
            String data = rs.getString("data");
            // System.out.println(data);
        }

        preparedStatement.close();
        return "{}";
    }

    public void close() throws SQLException {
        connection.close();
    }
}