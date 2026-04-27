export function validate(schema) {
  return (req, res, next) => {
    const parsed = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
    });

    if (!parsed.success) {
      return res.status(400).json({
        message: 'Validation error',
        issues: parsed.error.issues,
      });
    }

    req.validated = parsed.data;
    return next();
  };
}
