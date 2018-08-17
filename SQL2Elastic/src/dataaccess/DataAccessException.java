package dataaccess;

public class DataAccessException extends Exception 
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public DataAccessException(String cause)
	{
		super(cause);
	}
	
	public DataAccessException(String cause, Throwable tw)
	{
		super(cause, tw);
	}
}
