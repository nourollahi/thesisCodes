import java.io.File;
import java.io.FileNotFoundException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Scanner;

public class DAO {
	public static String getNewsFromDB(String agency,String id) throws SQLException {
		try {
			Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
			Connection conn = DriverManager.getConnection(
					"jdbc:sqlserver://mostafa-vaio\\sqlserver;databaseName=rigi;integratedSecurity=true");
			String selectTableSQL = "select content , my_content from  khabar WHERE id = ? and khabar_gozari=?";
			PreparedStatement preparedStatement = conn.prepareStatement(selectTableSQL);
			preparedStatement.setString(1, id);
			preparedStatement.setString(2, agency);
			ResultSet rs = preparedStatement.executeQuery();
			if (rs.next()) {
				String content = rs.getString(1);
				String myContent = rs.getString(2);
				if (!(myContent.equals(""))) {
					return myContent;
				} else {
					return content;
				}
			} else {
				System.err.println("doc with id " + id + " has no doc");
				return null;
			}
		} catch (ClassNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return null;
		}
	}
}