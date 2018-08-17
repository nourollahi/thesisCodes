package dataaccess;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

@JsonInclude(value=Include.NON_NULL)
public class NewsServiceResult 
{
	private int error_code;
	private String error = new String("");
	private Object result;
	private long time;
	private long resultCount;
	
	public NewsServiceResult()
	{
		
	}
	
	public NewsServiceResult(int errorCode, String error, Object result, long time, long resultCount)
	{
		this.error_code = errorCode;
		this.error = error;
		this.result = result;
		this.time = time;
		this.setResultCount(resultCount);
	}
	
	@JsonProperty("error_code")
	public int getErrorCode() {
		return error_code;
	}
	public void setErrorCode(int errorCode) {
		this.error_code = errorCode;
	}
	public String getError() {
		return error;
	}
	public void setError(String error) {
		this.error = error;
	}
	public Object getResult() {
		return result;
	}
	public void setResult(Object result) {
		this.result = result;
	}
	public long getTime() {
		return time;
	}
	public void setTime(long time) {
		this.time = time;
	}

	public long getResultCount() {
		return resultCount;
	}

	public void setResultCount(long resultCount) {
		this.resultCount = resultCount;
	}
}