package dataaccess;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;

public class FetchParseManager {

	public void fetchParseDocs() throws Exception {
		// logger.info("fetch and parse for single DB :: fetch part");
		String DBName = "tabnak";
		ArrayList<NewsBean> newsToBeIndexList = new ArrayList<NewsBean>();
		Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
		Connection conn = DriverManager.getConnection(
				"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=" + DBName + ";integratedSecurity=true");
		Statement sta = conn.createStatement();
		String Sql = "select id,titr,content,c_comment,year,month,day,hour,minute from khabar";
		ResultSet rs = sta.executeQuery(Sql);
		System.out.println("rs loaded");
		 int counter = 0;
		while (rs.next()) {
			/**
			 * create a list of doc to be index remember to add agency:)
			 */
			NewsBean tmp = new NewsBean(rs.getInt("id"), rs.getString("titr"), rs.getString("content"),
					rs.getInt("c_comment"), rs.getInt("year"), rs.getInt("month"), rs.getInt("day"), rs.getInt("hour"),
					rs.getInt("minute"));
			newsToBeIndexList.add(tmp);
			if (newsToBeIndexList.size() % 10000 == 0) {
				counter++;
				//System.out.println(newsToBeIndexList.size());
				System.out.println("indexing documents...");
				try {
					NewsSAO.indexBatchDoc(newsToBeIndexList, "news_index", "news_type", DBName);
				} catch (Exception e) {
					System.err.println("index error: " + e);
				}
				newsToBeIndexList.clear();
				System.out.println(counter+"0000 doc indexed");
			}
			
		}
		if (newsToBeIndexList.size() > 0) {
			try {
				NewsSAO.indexBatchDoc(newsToBeIndexList, "news_index", "news_type", DBName);
			} catch (Exception e) {
				System.err.println("index error: " + e);
			}

		}
		// System.out.println("indexing documents...");
		// try {
		// NewsSAO.indexBatchDoc(newsToBeIndexList, "index_name",
		// "index_type",DBName);
		// }
		// catch(Exception e)
		// {
		// System.err.println("index error: "+e);
		// }
		rs.close();
		System.out.println("rs closed");
		conn.close();
		System.out.println("conn closed");
		sta.close();
		System.out.println("sta closed");
		System.out.println("done");
		try {
			// NewsSAO.indexBatchDoc(toIndexDocs, "index name", "type name");
		} catch (Exception e) {
			// logger.fatal("Error in indexing documents", e);
			System.err.println("Error in indexing documents:" + e);
		}

	}

	public static void main(String[] args) {
		FetchParseManager ob = new FetchParseManager();
		try {
			ob.fetchParseDocs();
			// NewsBean testDoc = new NewsBean(2, "titr", "content", 1, 1, 1, 1,
			// 1, 1);
			// ArrayList<NewsBean> tmp = new ArrayList<>();
			// tmp.add(testDoc);
			// NewsSAO.indexBatchDoc(tmp, "news_index", "news_type",
			// "dbnametest");

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
