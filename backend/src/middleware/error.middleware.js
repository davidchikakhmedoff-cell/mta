import { StatusCodes } from 'http-status-codes';

export function errorHandler(err, req, res, next) {
  req.log?.error({ err }, 'Unhandled error');
  const status = err.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
  return res.status(status).json({
    message: err.message || 'Internal server error',
  });
}
