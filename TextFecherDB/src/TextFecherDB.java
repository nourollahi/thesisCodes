

import java.io.*;
import java.util.*;



import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class TextFecherDB {

    public static void main(String[] args) throws SQLException, ClassNotFoundException, IOException {
    	
    	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");	
		//Connection conn = DriverManager.getConnection("jdbc:sqlserver://localhost;user=;password=;database=ghatl_dadashi");
		Connection conn = DriverManager.getConnection("jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=ghatl_dadashi;integratedSecurity=true");
		Statement sta = conn.createStatement();
		 FileWriter fw = null;
	       BufferedWriter bw = null;
	       fw = new FileWriter("output/outputText.txt");
//	       fw = new FileWriter("output/CountComment.txt");
           bw = new BufferedWriter(fw);
		String Sql = "select * from khabarTagged ORDER BY [year] asc, [month] asc, [day] asc, [hour] asc, [minute] asc";
//		String Sql = "select c_comment,new_id,khabar_gozari from khabar ORDER BY [year] asc, [month] asc, [day] asc, [hour] asc, [minute] asc";
		//String otherFieildString;
		ResultSet rs = sta.executeQuery(Sql);
		int i=0;
		while (rs.next()) {
        
			//{ for content
					String otherFieildString = rs.getString("new_id")+","+rs.getString("khabar_gozari")+","+rs.getString("year")+","+rs.getString("month")+","+rs.getString("day")+","+rs.getString("hour")+","+rs.getString("minute");
					bw.write(","+(++i)+","+otherFieildString+"\n");
					String content = rs.getString("content");
		            bw.write(content+"\n");
            //}

			
            //{ for comment
//			String newID = rs.getString("new_id");
//			String c_comment = rs.getString("c_comment");
//			String khabargozari = rs.getString("khabar_gozari");
//			bw.write(newID+","+c_comment+","+khabargozari+"\n");
			
            
            //}
		}
		bw.close();
		System.out.println("Done");
    
       

    }


}
